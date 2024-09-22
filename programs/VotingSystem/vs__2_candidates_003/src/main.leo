import zvote_dao_registry.aleo;
import token_registry.aleo;

program vs__2_candidates_003.aleo {
    record CustodyReceipt {
        owner: address,
        amount: u128,
        token_id: field,
        external_authorization_required: bool,
        dao_id: field,
        proposal_id: field,
        candidate: field
    }

    struct ProposalKey {
        dao_id: field,
        proposal_id: field
    }

    struct ScoreKey {
        dao_id: field,
        proposal_id: field,
        candidate: field
    }

    struct ProposalParams {
        candidates: [field; 2]
    }

    struct VotingSystemParams {
        quorum: u128
    }

    mapping proposals: field => ProposalParams;
    // hash(ProposalKey) => ProposalParams
    mapping scores: field => u128;
    // hash(ScoreKey) => votes
    mapping custodies: field => u128;
    // hash(ScoreKey) => votes
    mapping voting_system_params: field => VotingSystemParams;
    // hash(VotingSystemParams) => VotingSystemParams


    inline max_u128(a: u128, b: u128) -> u128 {
        return a > b ? a : b;
    }


    async transition reference_voting_system_params(
        public params: VotingSystemParams
    ) -> Future {
        let vs_params_hash: field = BHP256::hash_to_field(params);
        return finalize_reference_voting_system_params(vs_params_hash, params);
    }
    async function finalize_reference_voting_system_params(
        vs_params_hash: field,
        params: VotingSystemParams
    ) {
        voting_system_params.set(vs_params_hash, params);
    }


    async transition initiate_proposal(
        public dao_id: field,
        public proposal_id: field,
        public proposal_params: ProposalParams,
        public vs_params: VotingSystemParams
    ) -> Future {
        let proposal_key: field = BHP256::hash_to_field(
            ProposalKey {
                dao_id: dao_id,
                proposal_id: proposal_id
            }
        );
        let vs_params_hash: field = BHP256::hash_to_field(
            vs_params
        );
        return finalize_initiate_proposal(
            dao_id, 
            proposal_key,
            proposal_params,
            vs_params_hash,
            self.caller
        );
    }
    async function finalize_initiate_proposal(
        dao_id: field,
        proposal_key: field,
        proposal_params: ProposalParams, // CANDIDATE_AMOUNT
        vs_params_hash: field,
        caller: address
    ) {
        assert(!proposals.contains(proposal_key));
        let proposal: Proposal = zvote_dao_registry.aleo/proposals.get(
            proposal_key
        );
        let dao: Dao = zvote_dao_registry.aleo/daos.get(
            dao_id
        );
        assert_eq(proposal.voting_system, self.address);
        assert_eq(proposal.vs_params_hash, vs_params_hash);
        assert_eq(dao.dao_manager, caller);
        
        proposals.set(proposal_key, proposal_params);
    }


    async transition cast_vote(
        public dao_id: field,
        public amount: u128,
        public proposal_id: field,
        public candidate: field,
        private token: token_registry.aleo/Token
    ) -> (
        token_registry.aleo/Token,
        CustodyReceipt, 
        Future
    ) {
        let proposal_key: field = BHP256::hash_to_field(
            ProposalKey {
                dao_id: dao_id,
                proposal_id: proposal_id
            }
        );
        let score_key: field = BHP256::hash_to_field(
            ScoreKey {
                dao_id: dao_id,
                proposal_id: proposal_id,
                candidate: candidate
            }
        );
        let (change, transfer_future): (
            token_registry.aleo/Token,
            Future
        ) = token_registry.aleo/transfer_private_to_public(
            self.address,
            amount,
            token
        );

        return (
            change, 
            CustodyReceipt {
                owner: self.signer,
                amount: amount,
                token_id: token.token_id,
                external_authorization_required: token.external_authorization_required,
                dao_id: dao_id,
                proposal_id: proposal_id,
                candidate: candidate
            },
            finalize_cast_vote(
                dao_id, token.token_id, amount, proposal_key, score_key, candidate, transfer_future
            )
        );
    }
    async function finalize_cast_vote(
        dao_id: field,
        token_id: field,
        amount: u128,
        proposal_key: field,
        score_key: field,
        candidate: field,
        transfer_future: Future
    ) {
        transfer_future.await();
        let dao: Dao = zvote_dao_registry.aleo/daos.get(dao_id);
        assert_eq(dao.token_id, token_id);
        
        let proposal_params: ProposalParams = proposals.get(proposal_key);

        assert(
            candidate == proposal_params.candidates[0u8]
            || candidate == proposal_params.candidates[1u8]
        );
        let former_score: u128 = scores.get_or_use(score_key, 0u128);
        scores.set(score_key, former_score + amount);
    }


    async transition withdraw_receipt(
        public amount: u128,
        private receipt: CustodyReceipt
    ) -> (CustodyReceipt, token_registry.aleo/Token, Future) {
        let proposal_key: field = BHP256::hash_to_field(
            ProposalKey {
                dao_id: receipt.dao_id,
                proposal_id: receipt.proposal_id
            }
        );
        let score_key: field = BHP256::hash_to_field(
            ScoreKey {
                dao_id: receipt.dao_id,
                proposal_id: receipt.proposal_id,
                candidate: receipt.candidate
            }
        );
        let (withdrawal, transfer_future): (
            token_registry.aleo/Token,
            Future
        ) = token_registry.aleo/transfer_public_to_private(
            receipt.token_id,
            receipt.owner,
            amount,
            receipt.external_authorization_required
        );

        return (
            CustodyReceipt {
                owner: self.signer,
                amount: receipt.amount - amount,
                token_id: receipt.token_id,
                external_authorization_required: receipt.external_authorization_required,
                dao_id: receipt.dao_id,
                proposal_id: receipt.proposal_id,
                candidate: receipt.candidate
            },
            withdrawal,
            finalize_withdraw_receipt(amount, score_key, receipt.candidate, transfer_future)
        );
    }
    async function finalize_withdraw_receipt(
        amount: u128,
        score_key: field,
        candidate: field,
        transfer_future: Future
    ) {
        transfer_future.await();
        let former_score: u128 = scores.get(score_key);
        scores.set(score_key, former_score - amount);
    }


    async transition set_result(
        public dao_id: field,
        public proposal_id: field,
        public winner: field
    ) -> (Future) {
        let proposal_key: field = BHP256::hash_to_field(
            ProposalKey {
                dao_id: dao_id,
                proposal_id: proposal_id
            }
        );

        let set_result_future: Future = zvote_dao_registry.aleo/set_result(
            dao_id,
            proposal_id,
            winner
        );

        return finalize_set_result(
            dao_id,
            proposal_id,
            proposal_key,
            winner,
            set_result_future
        );
    }
    async function finalize_set_result(
        dao_id: field,
        proposal_id: field,
        proposal_key: field,
        winner: field,
        set_result_future: Future
    ) {
        set_result_future.await();
        let proposal: Proposal = zvote_dao_registry.aleo/proposals.get(
            proposal_key
        );
        let proposal_params: ProposalParams = proposals.get(proposal_key);
        let vs_params: VotingSystemParams = voting_system_params.get(
            proposal.vs_params_hash
        );

        let candidate0_score_key: field = BHP256::hash_to_field(
            ScoreKey {
                dao_id: dao_id,
                proposal_id: proposal_id,
                candidate: proposal_params.candidates[0u8]
            }
        );
        let candidate0_score: u128 = scores.get(candidate0_score_key);

        let candidate1_score_key: field = BHP256::hash_to_field(
            ScoreKey {
                dao_id: dao_id,
                proposal_id: proposal_id,
                candidate: proposal_params.candidates[1u8]
            }
        );
        let candidate1_score: u128 = scores.get(candidate1_score_key);
        
        let maximum_score: u128 = max_u128(candidate0_score, candidate1_score);
        assert(maximum_score >= vs_params.quorum && candidate0_score != candidate1_score);
        let computed_winner: field = (candidate0_score > candidate1_score) ?
            proposal_params.candidates[0u8] :
            proposal_params.candidates[1u8];
        assert_eq(winner, computed_winner);
    }
}

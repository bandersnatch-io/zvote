import zvote_dao_registry_015.aleo;
import token_registry.aleo;

program vs__2_candidates_015.aleo {
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

    struct VotingSystemParams {
        quorum: u128
    }

    struct ProposalParams {
        end_block: u32
    }

    mapping scores: field => u128;
    // hash(ScoreKey) => votes
    mapping custodies: field => u128;
    // hash(ScoreKey) => votes
    mapping voting_system_params: field => VotingSystemParams;
    // hash(VotingSystemParams) => VotingSystemParams
    mapping proposal_params: field => ProposalParams;
    // hash(ProposalParams) => ProposalParams


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

    async transition reference_proposal_params(
        public params: ProposalParams
    ) -> Future {
        let proposal_params_hash: field = BHP256::hash_to_field(params);
        return finalize_reference_proposal_params(proposal_params_hash, params);
    }
    async function finalize_reference_proposal_params(
        proposal_params_hash: field,
        params: ProposalParams
    ) {
        proposal_params.set(proposal_params_hash, params);
    }


    async transition cast_vote(
        public dao_id: field,
        public proposal_id: field,
        public amount: u128,
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
        let dao: Dao = zvote_dao_registry_015.aleo/daos.get(dao_id);
        assert_eq(dao.token_id, token_id);

        let proposal: Proposal = zvote_dao_registry_015.aleo/proposals.get(proposal_key);
        let end_block: u32 = proposal_params.get(proposal.params_hash).end_block;
        assert(block.height < end_block);
        
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
        let set_result_future: Future = zvote_dao_registry_015.aleo/set_result(
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
        let proposal: Proposal = zvote_dao_registry_015.aleo/proposals.get(
            proposal_key
        );
        assert_eq(proposal.voting_system, self.address);

        let end_block: u32 = proposal_params.get(proposal.params_hash).end_block;
        assert(block.height >= end_block);

        let vs_params: VotingSystemParams = voting_system_params.get(
            proposal.vs_params_hash
        );

        let candidate0_score_key: field = BHP256::hash_to_field(
            ScoreKey {
                dao_id: dao_id,
                proposal_id: proposal_id,
                candidate: 0field
            }
        );
        let candidate0_score: u128 = scores.get_or_use(candidate0_score_key, 0u128);

        let candidate1_score_key: field = BHP256::hash_to_field(
            ScoreKey {
                dao_id: dao_id,
                proposal_id: proposal_id,
                candidate: 1field
            }
        );
        let candidate1_score: u128 = scores.get_or_use(candidate1_score_key, 0u128);
        
        let maximum_score: u128 = max_u128(candidate0_score, candidate1_score);
        assert(candidate0_score + candidate1_score >= vs_params.quorum);
        assert(candidate0_score != candidate1_score);
        let computed_winner: field = (candidate0_score > candidate1_score) ?
            0field :
            1field;
        assert_eq(winner, computed_winner);
    }
}

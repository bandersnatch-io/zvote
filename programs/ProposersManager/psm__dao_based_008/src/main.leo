import zvote_dao_registry_008.aleo;
import daom__approved_proposers_008.aleo;


program psm__dao_based_008.aleo {
    struct ProposalKey {
        dao_id: field,
        proposal_id: field,
    }

    struct ProposerProposal {
        dao_id: field,
        proposal_id: field,
        proposer: address,
        is_add: bool // or remove
    }
    mapping approve_proposer_proposals: field => ProposerProposal;
    // hash(ProposalKey) => proposer_proposal

    struct PSMApproveArgs {
        proposer: address,
        is_add: bool,
        is_proposers_approve_proposal: bool
    }

    async transition create_approve_proposal(
        public dao_id: field,
        public proposal_id: field,
        public proposer: address,
        public voting_system: address,
        public vs_params_hash: field,
        public is_add: bool
    ) -> Future {
        assert(is_add || proposer != self.address);
        let proposal_content: field = BHP256::hash_to_field(
            PSMApproveArgs{
                proposer: proposer,
                is_add: is_add,
                is_proposers_approve_proposal: true
            }
        );
        let create_proposal_future: Future =
            daom__approved_proposers_008.aleo/create_proposal(
                dao_id,
                proposal_id,
                proposal_content,
                voting_system,
                vs_params_hash
            );

        let proposer_proposal: ProposerProposal = ProposerProposal {
            dao_id: dao_id,
            proposal_id: proposal_id,
            proposer: proposer,
            is_add: is_add // or remove
        };

        let proposal_key: ProposalKey = ProposalKey {
            dao_id: dao_id,
            proposal_id: proposal_id
        };
        let proposal_key_hash: field = BHP256::hash_to_field(proposal_key);
        return finalize_create_approve_proposal(
            proposal_key_hash,
            proposer_proposal,
            create_proposal_future,
        );
    }
    async function finalize_create_approve_proposal(
        proposal_key_hash: field,
        proposer_proposal: ProposerProposal,
        create_proposal_future: Future
    ) {
        create_proposal_future.await();
        let exists: bool = approve_proposer_proposals.contains(
            proposal_key_hash
        );
        assert(!exists);
        approve_proposer_proposals.set(proposal_key_hash, proposer_proposal);
    }


    async transition add_approved_proposer(
        public dao_id: field,
        public proposal_id: field,
        public proposer: address
    ) -> Future {
        let approve_proposer_future: Future =
            daom__approved_proposers_008.aleo/add_approved_proposer(
                dao_id,
                proposer
            );
        let proposal_key: ProposalKey = ProposalKey {
            dao_id: dao_id,
            proposal_id: proposal_id
        };
        let proposal_key_hash: field = BHP256::hash_to_field(proposal_key);
        return finalize_add_approved_proposer(
            proposal_key_hash,
            proposer,
            approve_proposer_future,
        );
    }
    async function finalize_add_approved_proposer(
        proposal_key_hash: field,
        proposer: address,
        approve_proposer_future: Future
    ){
        let proposer_proposal: ProposerProposal =
            approve_proposer_proposals.get(proposal_key_hash);
        assert_eq(proposer_proposal.proposer, proposer);
        assert(proposer_proposal.is_add);
        approve_proposer_proposals.remove(proposal_key_hash);

        let vote_result: bool = zvote_dao_registry_008.aleo/results.get(
            proposal_key_hash
        ) as bool;
        assert(vote_result);

        approve_proposer_future.await();
    }


    async transition remove_approved_proposer(
        public dao_id: field,
        public proposal_id: field,
        public proposer: address
    ) -> Future {
        let remove_proposer_future: Future =
            daom__approved_proposers_008.aleo/remove_approved_proposer(
                dao_id,
                proposer
            );
        let proposal_key: ProposalKey = ProposalKey {
            dao_id: dao_id,
            proposal_id: proposal_id
        };
        let proposal_key_hash: field = BHP256::hash_to_field(proposal_key);
        return finalize_remove_approved_proposer(
            proposal_key_hash,
            proposer,
            remove_proposer_future
        );
    }
    async function finalize_remove_approved_proposer(
        proposal_key_hash: field,
        proposer: address,
        remove_proposer_future: Future
    ){
        let proposer_proposal: ProposerProposal =
            approve_proposer_proposals.get(proposal_key_hash);
        assert_eq(proposer_proposal.proposer, proposer);
        assert(!proposer_proposal.is_add);
        approve_proposer_proposals.remove(proposal_key_hash);

        let vote_result: bool = zvote_dao_registry_008.aleo/results.get(
            proposal_key_hash
        ) as bool;
        assert(vote_result);
        remove_proposer_future.await();
    }
}

import zvote_dao_registry_015.aleo;
import daom__approved_proposers_015.aleo;


program daomu__dao_based_ap_015.aleo {
    struct ProposalKey {
        dao_id: field,
        proposal_id: field,
    }

    struct DAOMUpdateProposal {
        dao_id: field,
        proposal_id: field,
        token_id: field,
        dao_manager: address,
        dao_manager_params_hash: field,
    }

    mapping proposal_contents: field => DAOMUpdateProposal;
    // hash(ProposalKey) => DAOMUpdateProposal

    mapping executed_already: field => bool;
    // hash(ProposalKey) => has_been_executed_already

    async transition create_daom_update_proposal(
        public dao_id: field,
        public proposal_id: field,
        public proposal_params_hash: field,
        public new_token_id: field,
        public dao_manager: address,
        public dao_manager_params_hash: field,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let create_proposal_future: Future =
            daom__approved_proposers_015.aleo/create_proposal(
                dao_id,
                proposal_id,
                self.address,
                proposal_params_hash,
                voting_system,
                vs_params_hash
            );

        let daom_update_proposal: DAOMUpdateProposal = DAOMUpdateProposal {
            dao_id: dao_id,
            proposal_id: proposal_id,
            token_id: new_token_id,
            dao_manager: dao_manager,
            dao_manager_params_hash: dao_manager_params_hash
        };

        let proposal_key: ProposalKey = ProposalKey {
            dao_id: dao_id,
            proposal_id: proposal_id
        };
        let proposal_key_hash: field = BHP256::hash_to_field(proposal_key);
        return finalize_create_daom_update_proposal(
            proposal_key_hash,
            daom_update_proposal,
            create_proposal_future,
        );
    }
    async function finalize_create_daom_update_proposal(
        proposal_key_hash: field,
        daom_update_proposal: DAOMUpdateProposal,
        create_proposal_future: Future
    ) {
        create_proposal_future.await();
        let exists: bool = proposal_contents.contains(proposal_key_hash);
        assert(!exists);
        proposal_contents.set(proposal_key_hash, daom_update_proposal);
    }


    async transition update_dao_manager(
        public dao_id: field,
        public proposal_id: field,
        public new_token_id: field,
        public new_dao_manager: address,
        public dao_manager_params_hash: field
    ) -> Future {
        let update_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/update_dao_manager(
                dao_id,
                new_token_id,
                new_dao_manager,
                dao_manager_params_hash
            );
        let proposal_key: ProposalKey = ProposalKey {
            dao_id: dao_id,
            proposal_id: proposal_id
        };
        let proposal_key_hash: field = BHP256::hash_to_field(proposal_key);
        return finalize_update_dao_manager(
            proposal_key_hash,
            new_token_id,
            new_dao_manager,
            dao_manager_params_hash,
            update_dao_manager_future,
        );
    }
    async function finalize_update_dao_manager(
        proposal_key_hash: field,
        new_token_id: field,
        new_dao_manager: address,
        dao_manager_params_hash: field,
        update_dao_manager_future: Future
    ){
        let daom_update_proposal: DAOMUpdateProposal =
            proposal_contents.get(proposal_key_hash);
        assert_eq(daom_update_proposal.dao_manager, new_dao_manager);
        assert_eq(daom_update_proposal.token_id, new_token_id);
        assert_eq(dao_manager_params_hash, daom_update_proposal.dao_manager_params_hash);

        let vote_result: bool = zvote_dao_registry_015.aleo/results.get(
            proposal_key_hash
        ) as bool;
        assert(vote_result);

        assert(executed_already.contains(proposal_key_hash).not());
        executed_already.set(proposal_key_hash, true);

        update_dao_manager_future.await();
    }
}

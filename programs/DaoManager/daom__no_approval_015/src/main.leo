import zvote_dao_registry_015.aleo;


program daom__no_approval_015.aleo {
    struct NaDaoManagerParams{
        dao_manager_updater: address,
        voting_system_manager: address,
    }
    mapping dao_manager_params: field => NaDaoManagerParams;
    // hash(NaDaoManagerParams) => NaDaoManagerParams
    

    async transition init_as_dao_manager(
        public dao_id: field,
        public daom_params: NaDaoManagerParams,
    ) -> Future {
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            daom_params
        );

        return finalize_init_as_dao_manager(
            dao_id,
            daom_params,
            dao_manager_params_hash
        );
    }
    async function finalize_init_as_dao_manager(
        dao_id: field,
        daom_params: NaDaoManagerParams,
        dao_manager_params_hash: field
    ) {
        let dao: Dao = zvote_dao_registry_015.aleo/daos.get(dao_id);
        assert_eq(dao.dao_manager, self.address);
        assert_eq(dao.dao_manager_params_hash, dao_manager_params_hash);
        dao_manager_params.set(
            dao_manager_params_hash,
            daom_params
        );
    }


    async transition reference_dao_manager_params(
        public daom_params: NaDaoManagerParams,
    ) -> Future {
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            daom_params
        );

        return finalize_reference_dao_manager_params(
            daom_params,
            dao_manager_params_hash
        );
    }
    async function finalize_reference_dao_manager_params(
        daom_params: NaDaoManagerParams,
        dao_manager_params_hash: field
    ) {
        dao_manager_params.set(
            dao_manager_params_hash,
            daom_params
        );
    }


    async transition update_dao_manager(
        public dao_id: field,
        public new_token_id: field,
        public new_dao_manager: address,
        public dao_manager_params_hash: field
    ) -> Future {
        let update_dao_manager_future: Future =
            zvote_dao_registry_015.aleo/update_dao_manager(
                dao_id, new_token_id, new_dao_manager, dao_manager_params_hash
            );
        return finalize_update_dao_manager(
            dao_id,
            self.caller,
            update_dao_manager_future
        );
    }
    async function finalize_update_dao_manager(
        dao_id: field,
        caller: address,
        update_dao_manager_future: Future
    ) {
        let dao: Dao = zvote_dao_registry_015.aleo/daos.get(dao_id);
        let daom_params: NaDaoManagerParams =
            dao_manager_params.get(dao.dao_manager_params_hash);
        let dao_manager_updater: address = daom_params.dao_manager_updater;
        assert_eq(dao_manager_updater, caller);

        update_dao_manager_future.await();
    }

    async transition update_dao_manager_as_signer(
        public dao_id: field,
        public new_token_id: field,
        public new_dao_manager: address,
        public dao_manager_params_hash: field
    ) -> Future {
        let update_dao_manager_future: Future =
            zvote_dao_registry_015.aleo/update_dao_manager(
                dao_id, new_token_id, new_dao_manager, dao_manager_params_hash
            );
        return finalize_update_dao_manager(
            dao_id,
            self.signer,
            update_dao_manager_future
        );
    }


    async transition add_voting_system(
        public dao_id: field,
        public new_voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let add_voting_system_future: Future = 
            zvote_dao_registry_015.aleo/add_voting_system(
                dao_id,
                new_voting_system,
                vs_params_hash
            );
        return finalize_add_voting_system(
            dao_id, self.caller, add_voting_system_future
        );
    }
    async function finalize_add_voting_system(
        dao_id: field,
        caller: address,
        add_voting_system_future: Future,
    ) {
        let dao: Dao = zvote_dao_registry_015.aleo/daos.get(dao_id);
        let daom_params: NaDaoManagerParams =
            dao_manager_params.get(dao.dao_manager_params_hash);
        let voting_system_manager: address = daom_params.voting_system_manager;
        assert_eq(caller, voting_system_manager);
       add_voting_system_future.await();
    }


    async transition remove_voting_system(
        public dao_id: field,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let remove_voting_system_future: Future = 
            zvote_dao_registry_015.aleo/remove_voting_system(
                dao_id,
                voting_system,
                vs_params_hash 
            );
        return finalize_remove_voting_system(
            dao_id, self.caller, remove_voting_system_future
        );
    }
    async function finalize_remove_voting_system(
        dao_id: field,
        caller: address,
        remove_voting_system_future: Future
    ) {
        let dao: Dao = zvote_dao_registry_015.aleo/daos.get(dao_id);
        let daom_params: NaDaoManagerParams =
            dao_manager_params.get(dao.dao_manager_params_hash);
        let voting_system_manager: address = daom_params.voting_system_manager;
        assert_eq(caller, voting_system_manager);
       remove_voting_system_future.await();
    }


    async transition create_proposal(
        public dao_id: field,
        public proposal_id: field,
        public proposal_content: address,
        public proposal_params_hash: field,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let create_proposal_future: Future = 
            zvote_dao_registry_015.aleo/create_proposal(
                dao_id, proposal_id, proposal_content, proposal_params_hash, voting_system, vs_params_hash
            );
        return finalize_create_proposal(
            create_proposal_future,
        );
    }
    async function finalize_create_proposal(
        create_proposal_future: Future
    ) {
        create_proposal_future.await();
    }
}

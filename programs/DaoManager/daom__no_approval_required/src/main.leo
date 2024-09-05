import multi_dao_support_program.aleo;


program daom__no_approval_required.aleo {
    mapping dao_manager_updaters: field => address;
    // dao_id => dao_manager_updater
    mapping voting_system_managers: field => address;
    // dao_id => voting_system_manager


    async transition init_as_dao_manager(
        public dao_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
    ) -> Future {
        let update_dao_manager_future: Future =
            multi_dao_support_program.aleo/update_dao_manager(
                dao_id, self.address
            );
        return finalize_init_as_dao_manager(
            dao_id,
            voting_system_manager,
            dao_manager_updater,
            update_dao_manager_future
        );
    }
    async function finalize_init_as_dao_manager(
        dao_id: field,
        voting_system_manager: address,
        dao_manager_updater: address,
        update_dao_manager_future: Future
    ) {
        update_dao_manager_future.await();
        dao_manager_updaters.set(dao_id, dao_manager_updater);
        voting_system_managers.set(dao_id, voting_system_manager);
    }


    async transition update_dao_manager(
        public dao_id: field,
        public new_dao_manager: address
    ) -> Future {
        let update_dao_manager_future: Future =
            multi_dao_support_program.aleo/update_dao_manager(
                dao_id, new_dao_manager
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
        update_dao_manager_future.await();
        let dao_manager_updater: address =
            dao_manager_updaters.get(dao_id);
        assert_eq(dao_manager_updater, caller);

        dao_manager_updaters.remove(dao_id);
        voting_system_managers.remove(dao_id);
    }


    async transition add_voting_system(
        public dao_id: field,
        public new_voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let add_voting_system_future: Future = 
            multi_dao_support_program.aleo/add_voting_system(
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
        let voting_system_manager: address = voting_system_managers.get(
            dao_id
        );
        assert_eq(caller, voting_system_manager);
       add_voting_system_future.await();
    }


    async transition remove_voting_system(
        public dao_id: field,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let remove_voting_system_future: Future = 
            multi_dao_support_program.aleo/remove_voting_system(
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
        let voting_system_manager: address = voting_system_managers.get(
            dao_id
        );
        assert_eq(caller, voting_system_manager);
       remove_voting_system_future.await();
    }


    async transition create_proposal(
        public dao_id: field,
        public proposal_id: field,
        public content: field,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let create_proposal_future: Future = 
            multi_dao_support_program.aleo/create_proposal(
                dao_id, proposal_id, content, voting_system, vs_params_hash
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

import multi_dao_support_program.aleo;


program daom__approved_proposers_001.aleo {
    struct ProposerKey {
        dao_id: field,
        proposer: address,
    }

    mapping dao_manager_updaters: field => address;
    // dao_id => dao_manager_updater
    mapping voting_system_managers: field => address;
    // dao_id => voting_system_manager
    mapping proposers_managers: field => address;
    // dao_id => proposers_manager
    mapping approved_proposers: field => ProposerKey;
    // hash(ProposerKey) => is_approved_proposer


    async transition init_as_dao_manager(
        public dao_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public proposers_manager: address,
    ) -> Future {
        let update_dao_manager_future: Future =
            multi_dao_support_program.aleo/update_dao_manager(
                dao_id, self.address
            );
        let dao_manager_updater_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: dao_manager_updater
            }
        );
        let voting_system_manager_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: voting_system_manager
            }
        );
        let proposer_manager_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: proposers_manager
            }
        );
        return finalize_init_as_dao_manager(
            dao_id,
            voting_system_manager,
            voting_system_manager_hash_key,
            dao_manager_updater,
            dao_manager_updater_hash_key,
            proposers_manager,
            proposer_manager_hash_key,
            update_dao_manager_future
        );
    }
    async function finalize_init_as_dao_manager(
        dao_id: field,
        voting_system_manager: address,
        voting_system_manager_hash_key: field,
        dao_manager_updater: address,
        dao_manager_updater_hash_key: field,
        proposers_manager: address,
        proposers_manager_hash_key: field,
        update_dao_manager_future: Future
    ) {
        update_dao_manager_future.await();
        let exists: bool = proposers_managers.contains(dao_id);
        assert(!exists);
        proposers_managers.set(dao_id, proposers_manager);
        dao_manager_updaters.set(dao_id, dao_manager_updater);
        voting_system_managers.set(dao_id, voting_system_manager);

        approved_proposers.set(
            dao_manager_updater_hash_key,
            ProposerKey {
                dao_id: dao_id,
                proposer: dao_manager_updater
            }
        );
        approved_proposers.set(
            voting_system_manager_hash_key,
            ProposerKey {
                dao_id: dao_id,
                proposer: voting_system_manager
            }
        );
        approved_proposers.set(
            proposers_manager_hash_key,
            ProposerKey {
                dao_id: dao_id,
                proposer: proposers_manager
            }
        );
    }


    async transition update_dao_manager(
        public dao_id: field,
        public new_dao_manager: address
    ) -> Future {
        let update_dao_manager_future: Future =
            multi_dao_support_program.aleo/update_dao_manager(
                dao_id, new_dao_manager
            );
        let dao_manager_updater_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: self.caller,
            }
        );
        return finalize_update_dao_manager(
            dao_id,
            self.caller,
            dao_manager_updater_hash_key,
            update_dao_manager_future
        );
    }
    async function finalize_update_dao_manager(
        dao_id: field,
        caller: address,
        dao_manager_updater_hash_key: field,
        update_dao_manager_future: Future
    ) {
        update_dao_manager_future.await();
        let dao_manager_updater: address =
            dao_manager_updaters.get(dao_id);
        assert_eq(dao_manager_updater, caller);

        let voting_system_manager: address = 
            voting_system_managers.get(dao_id);
        let voting_system_manager_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: voting_system_manager,
            }
        );

        let proposers_manager: address = 
            proposers_managers.get(dao_id);
        let proposers_managers_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: proposers_manager,
            }
        );

        proposers_managers.remove(dao_id);
        dao_manager_updaters.remove(dao_id);
        voting_system_managers.remove(dao_id);

        approved_proposers.remove(dao_manager_updater_hash_key);
        approved_proposers.remove(voting_system_manager_hash_key);
        approved_proposers.remove(proposers_managers_hash_key);
    }


    async transition add_approved_proposer(
        public dao_id: field,
        public proposer: address,
    ) -> Future {
        let proposer_id: ProposerKey = ProposerKey {
            dao_id: dao_id,
            proposer: proposer,
        };
        let proposer_key: field = BHP256::hash_to_field(proposer_id);
        return finalize_add_approved_proposer(dao_id, proposer_key, proposer, self.caller);
    }
    async function finalize_add_approved_proposer(
        dao_id: field, proposer_key: field, proposer: address, caller: address
    ) {
        let proposers_manager: address = proposers_managers.get(dao_id);
        assert_eq(proposers_manager, caller);

        approved_proposers.set(
            proposer_key,
            ProposerKey {
                dao_id: dao_id,
                proposer: proposer
            }
        );
    }


    async transition remove_approved_proposer(
        public dao_id: field,
        public proposer: address,
    ) -> Future {
        let proposer_id: ProposerKey = ProposerKey {
            dao_id: dao_id,
            proposer: proposer,
        };
        let proposer_key: field = BHP256::hash_to_field(proposer_id);
        return finalize_remove_approved_proposer(
            dao_id, proposer_key, self.caller
        );
    }
    async function finalize_remove_approved_proposer(
        dao_id: field, proposer_key: field, caller: address
    ) {
        let proposers_manager: address = proposers_managers.get(dao_id);
        assert_eq(proposers_manager, caller);
        approved_proposers.remove(proposer_key);
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
        let proposer_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: self.caller
            }
        );
        let create_proposal_future: Future = 
            multi_dao_support_program.aleo/create_proposal(
                dao_id, proposal_id, content, voting_system, vs_params_hash
            );
        return finalize_create_proposal(
            proposer_key, create_proposal_future,
        );
    }
    async function finalize_create_proposal(
        proposer_key: field, create_proposal_future: Future
    ) {
        let approved: bool = approved_proposers.contains(proposer_key);
        assert(approved);
        create_proposal_future.await();
    }
}

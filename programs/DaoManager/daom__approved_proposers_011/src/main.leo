import zvote_dao_registry_011.aleo;


program daom__approved_proposers_011.aleo {
    struct ProposerKey {
        dao_id: field,
        proposer: address,
    }

    mapping approved_proposers: field => ProposerKey;
    // hash(ProposerKey) => is_approved_proposer

    struct ApDaoManagerParams{
        dao_manager_updater: address,
        voting_system_manager: address,
        proposers_manager: address,
    }

    mapping dao_manager_params: field => ApDaoManagerParams;
    // hash(ApDaoManagerParams) => ApDaoManagerParams
    

    async transition init_as_dao_manager(
        public dao_id: field,
        public daom_params: ApDaoManagerParams,
    ) -> Future {
        let dao_manager_updater_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.dao_manager_updater
            }
        );
        let voting_system_manager_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.voting_system_manager
            }
        );
        let proposer_manager_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.proposers_manager
            }
        );
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            daom_params
        );
        return finalize_init_as_dao_manager(
            dao_id,
            daom_params,
            dao_manager_params_hash,
            voting_system_manager_hash_key,
            dao_manager_updater_hash_key,
            proposer_manager_hash_key,
        );
    }
    async function finalize_init_as_dao_manager(
        dao_id: field,
        daom_params: ApDaoManagerParams,
        dao_manager_params_hash: field,
        voting_system_manager_hash_key: field,
        dao_manager_updater_hash_key: field,
        proposers_manager_hash_key: field,
    ) {
        let dao: Dao = zvote_dao_registry_011.aleo/daos.get(dao_id);
        assert_eq(dao.dao_manager, self.address);
        assert_eq(dao.dao_manager_params_hash, dao_manager_params_hash);
        dao_manager_params.set(
            dao_manager_params_hash,
            daom_params
        );
        approved_proposers.set(
            dao_manager_updater_hash_key,
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.dao_manager_updater
            }
        );
        approved_proposers.set(
            voting_system_manager_hash_key,
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.voting_system_manager
            }
        );
        approved_proposers.set(
            proposers_manager_hash_key,
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.proposers_manager
            }
        );
    }


    async transition reference_dao_manager_params(
        public daom_params: ApDaoManagerParams,
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
        daom_params: ApDaoManagerParams,
        dao_manager_params_hash: field
    ) {
        dao_manager_params.set(
            dao_manager_params_hash,
            daom_params
        );
    }


    async transition update_dao_manager(
        public dao_id: field,
        public new_dao_manager: address,
        public dao_manager_params_hash: field
    ) -> Future {
        let update_dao_manager_future: Future =
            zvote_dao_registry_011.aleo/update_dao_manager(
                dao_id, new_dao_manager, dao_manager_params_hash
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
        let dao: Dao = zvote_dao_registry_011.aleo/daos.get(dao_id);
        let daom_params: ApDaoManagerParams =
            dao_manager_params.get(dao.dao_manager_params_hash);
        assert_eq(daom_params.dao_manager_updater, caller);

        let voting_system_manager_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.voting_system_manager,
            }
        );
        let proposers_managers_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.proposers_manager,
            }
        );
        let dao_manager_updater_hash_key: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: daom_params.dao_manager_updater,
            }
        );
        update_dao_manager_future.await();

        approved_proposers.remove(dao_manager_updater_hash_key);
        approved_proposers.remove(voting_system_manager_hash_key);
        approved_proposers.remove(proposers_managers_hash_key);
    }


    async transition update_dao_manager_as_signer(
        public dao_id: field,
        public new_dao_manager: address,
        public dao_manager_params_hash: field
    ) -> Future {
        let update_dao_manager_future: Future =
            zvote_dao_registry_011.aleo/update_dao_manager(
                dao_id, new_dao_manager, dao_manager_params_hash
            );
        return finalize_update_dao_manager(
            dao_id,
            self.signer,
            update_dao_manager_future
        );
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
        let dao: Dao = zvote_dao_registry_011.aleo/daos.get(dao_id);
        let daom_params: ApDaoManagerParams =
            dao_manager_params.get(dao.dao_manager_params_hash);
        let proposers_manager: address = daom_params.proposers_manager;
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
        let dao: Dao = zvote_dao_registry_011.aleo/daos.get(dao_id);
        let daom_params: ApDaoManagerParams =
            dao_manager_params.get(dao.dao_manager_params_hash);
        let proposers_manager: address = daom_params.proposers_manager;
        assert_eq(proposers_manager, caller);
        approved_proposers.remove(proposer_key);
    }


    async transition add_voting_system(
        public dao_id: field,
        public new_voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let add_voting_system_future: Future = 
            zvote_dao_registry_011.aleo/add_voting_system(
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
        let dao: Dao = zvote_dao_registry_011.aleo/daos.get(dao_id);
        let daom_params: ApDaoManagerParams =
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
            zvote_dao_registry_011.aleo/remove_voting_system(
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
        let dao: Dao = zvote_dao_registry_011.aleo/daos.get(dao_id);
        let daom_params: ApDaoManagerParams =
            dao_manager_params.get(dao.dao_manager_params_hash);
        let voting_system_manager: address = daom_params.voting_system_manager;
        assert_eq(caller, voting_system_manager);
       remove_voting_system_future.await();
    }


    async transition create_proposal(
        public dao_id: field,
        public proposal_id: field,
        public proposal_content: address,
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
            zvote_dao_registry_011.aleo/create_proposal(
                dao_id, proposal_id, proposal_content, voting_system, vs_params_hash
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

import zvote_dao_registry_015.aleo;
import daom__approved_proposers_015.aleo;
import daom__no_approval_015.aleo;


program zvote_dao_factory_015.aleo {
    async transition register_proposer_list_dao(
        public dao_id: field,
        public token_id: field,
        public initial_voting_system: address,
        public initial_vs_params_hash: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public proposers_manager: address,
    ) -> Future {
        let dao_manager_params: ApDaoManagerParams = ApDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
            proposers_manager: proposers_manager
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );
        let register_dao_future: Future =
            zvote_dao_registry_015.aleo/register_dao(
                dao_id,
                token_id,
                daom__approved_proposers_015.aleo,
                dao_manager_params_hash,
                initial_voting_system,
                initial_vs_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_register_proposer_list_dao(
            register_dao_future,
            init_as_dao_manager_future
        );
    }
    async function finalize_register_proposer_list_dao(
        register_dao_future: Future,
        init_as_dao_manager_future: Future
    ) {
        register_dao_future.await();
        init_as_dao_manager_future.await();
    }


    async transition register_any_proposer_dao(
        public dao_id: field,
        public token_id: field,
        public initial_voting_system: address,
        public initial_vs_params_hash: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
    ) -> Future {
        let dao_manager_params: NaDaoManagerParams = NaDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );
        let register_dao_future: Future =
            zvote_dao_registry_015.aleo/register_dao(
                dao_id,
                token_id,
                daom__no_approval_015.aleo,
                dao_manager_params_hash,
                initial_voting_system,
                initial_vs_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_register_any_proposer_dao(
            register_dao_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_register_any_proposer_dao(
        register_dao_future: Future,
        init_as_dao_manager_future: Future
    ) {
        register_dao_future.await();
        init_as_dao_manager_future.await();
    }

}

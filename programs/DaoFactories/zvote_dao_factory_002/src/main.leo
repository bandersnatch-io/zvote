import multi_dao_support_program.aleo;
import daom__approved_proposers_001.aleo;
import daom__no_approval_required.aleo;

program zvote_dao_factory_002.aleo {
    async transition register_proposer_list_dao(
        public dao_id: field,
        public token_id: field,
        public initial_voting_system: address,
        public initial_vs_params_hash: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public proposers_manager: address,
    ) -> Future {
        let register_dao_future: Future =
            multi_dao_support_program.aleo/register_dao(
                dao_id,
                token_id,
                daom__approved_proposers_001.aleo,
                initial_voting_system,
                initial_vs_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_001.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_updater,
                voting_system_manager,
                proposers_manager
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
        let register_dao_future: Future =
            multi_dao_support_program.aleo/register_dao(
                dao_id,
                token_id,
                daom__no_approval_required.aleo,
                initial_voting_system,
                initial_vs_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_required.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_updater,
                voting_system_manager,
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

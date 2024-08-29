import multi_dao_support_program.aleo;
import daom__approved_proposer_list.aleo;
import psm__dao_based.aleo;
import daomu__dao_based.aleo;
import vsm__dao_based.aleo;


program zvote_dao_factory.aleo {
    async transition register_dao(
        public dao_id: field,
        public token_id: field,
        public initial_voting_system: address,
        public initial_vs_params_hash: field
    ) -> Future {
        let register_dao_future: Future =
            multi_dao_support_program.aleo/register_dao(
                dao_id,
                token_id,
                daom__approved_proposer_list.aleo
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposer_list.aleo/init_as_dao_manager(
                dao_id,
                vsm__dao_based.aleo,
                daomu__dao_based.aleo,
                psm__dao_based.aleo
            );
        let init_as_proposers_manager_future: Future =
            psm__dao_based.aleo/init_as_proposers_manager(
                dao_id
            );
        let init_as_vs_future: Future =
            vsm__dao_based.aleo/init_as_voting_system_manager(
                dao_id,
                initial_voting_system,
                initial_vs_params_hash
            );
        return finalize_register_dao(
            register_dao_future,
            init_as_dao_manager_future,
            init_as_proposers_manager_future,
            init_as_vs_future
        );
    }
    async function finalize_register_dao(
        register_dao_future: Future,
        init_as_dao_manager_future: Future,
        init_as_proposers_manager_future: Future,
        init_as_vs_future: Future
    ) {
        register_dao_future.await();
        init_as_dao_manager_future.await();
        init_as_proposers_manager_future.await();
        init_as_vs_future.await();
    }
}

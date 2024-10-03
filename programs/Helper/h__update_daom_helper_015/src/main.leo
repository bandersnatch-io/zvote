import daom__approved_proposers_015.aleo;
import daom__no_approval_015.aleo;
import daomu__dao_based_ap_015.aleo;
import daomu__dao_based_na_015.aleo;

program h__update_daom_helper_015.aleo {

    /*
    Update dao settings:
    */

    /*
    Fomer DAO manager: daom__approved_proposers_015.aleo
    New DAO manager: daom__no_approval_015.aleo
    */
    async transition update_ap_to_na(
        public dao_id: field,
        public token_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address
    ) -> Future {
        let dao_manager_params: NaDaoManagerParams = NaDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );

        let update_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/update_dao_manager_as_signer(
                dao_id, token_id, daom__no_approval_015.aleo, dao_manager_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_update_ap_to_na(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_update_ap_to_na(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }


    async transition update_na_to_ap(
        public dao_id: field,
        public token_id: field,
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

        let update_dao_manager_future: Future =
            daom__no_approval_015.aleo/update_dao_manager_as_signer(
                dao_id, token_id, daom__approved_proposers_015.aleo, dao_manager_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_update_na_to_ap(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_update_na_to_ap(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }


    async transition update_na_to_na(
        public dao_id: field,
        public token_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address
    ) -> Future {
        let dao_manager_params: NaDaoManagerParams = NaDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );

        let update_dao_manager_future: Future =
            daom__no_approval_015.aleo/update_dao_manager_as_signer(
                dao_id, token_id, daom__no_approval_015.aleo, dao_manager_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_update_na_to_na(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_update_na_to_na(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }


    async transition update_ap_to_ap(
        public dao_id: field,
        public token_id: field,
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

        let update_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/update_dao_manager_as_signer(
                dao_id, token_id, daom__approved_proposers_015.aleo, dao_manager_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_update_ap_to_ap(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_update_ap_to_ap(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }


    async transition propose_update_ap_to_na(
        public dao_id: field,
        public proposal_id: field,
        public proposal_params_hash: field,
        public token_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let dao_manager_params: NaDaoManagerParams = NaDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );

        let update_dao_manager_future: Future =
            daomu__dao_based_ap_015.aleo/create_daom_update_proposal(
                dao_id, proposal_id, proposal_params_hash, token_id, daom__no_approval_015.aleo, dao_manager_params_hash, voting_system, vs_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_015.aleo/reference_dao_manager_params(
                dao_manager_params
            );
        return finalize_propose_update_ap_to_na(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_propose_update_ap_to_na(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }



    async transition propose_update_na_to_ap(
        public dao_id: field,
        public proposal_id: field,
        public proposal_params_hash: field,
        public token_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public proposers_manager: address,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let dao_manager_params: ApDaoManagerParams = ApDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
            proposers_manager: proposers_manager
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );

        let update_dao_manager_future: Future =
            daomu__dao_based_na_015.aleo/create_daom_update_proposal(
                dao_id, proposal_id, proposal_params_hash, token_id, daom__approved_proposers_015.aleo, dao_manager_params_hash, voting_system, vs_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/reference_dao_manager_params(
                dao_manager_params
            );
        return finalize_propose_update_na_to_ap(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_propose_update_na_to_ap(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }



    async transition propose_update_na_to_na(
        public dao_id: field,
        public proposal_id: field,
        public proposal_params_hash: field,
        public token_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let dao_manager_params: NaDaoManagerParams = NaDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );

        let update_dao_manager_future: Future =
            daomu__dao_based_na_015.aleo/create_daom_update_proposal(
                dao_id, proposal_id, proposal_params_hash, token_id, daom__no_approval_015.aleo, dao_manager_params_hash, voting_system, vs_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_015.aleo/reference_dao_manager_params(
                dao_manager_params
            );
        return finalize_propose_update_na_to_na(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_propose_update_na_to_na(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }


    async transition propose_update_ap_to_ap(
        public dao_id: field,
        public proposal_id: field,
        public proposal_params_hash: field,
        public token_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public proposers_manager: address,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let dao_manager_params: ApDaoManagerParams = ApDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
            proposers_manager: proposers_manager
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );

        let update_dao_manager_future: Future =
            daomu__dao_based_ap_015.aleo/create_daom_update_proposal(
                dao_id, proposal_id, proposal_params_hash, token_id, daom__approved_proposers_015.aleo, dao_manager_params_hash, voting_system, vs_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/reference_dao_manager_params(
                dao_manager_params
            );
        return finalize_propose_update_ap_to_ap(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_propose_update_ap_to_ap(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }



    async transition dao_based_update_ap_to_na(
        public dao_id: field,
        public proposal_id: field,
        public token_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address
    ) -> Future {
        let dao_manager_params: NaDaoManagerParams = NaDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );

        let update_dao_manager_future: Future =
            daomu__dao_based_ap_015.aleo/update_dao_manager(
                dao_id, proposal_id, token_id, daom__no_approval_015.aleo, dao_manager_params_hash,
            );

        let init_as_dao_manager_future: Future =
            daom__no_approval_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_dao_based_update_ap_to_na(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_dao_based_update_ap_to_na(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }


    async transition dao_based_update_na_to_ap(
        public dao_id: field,
        public proposal_id: field,
        public token_id: field,
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

        let update_dao_manager_future: Future =
            daomu__dao_based_na_015.aleo/update_dao_manager(
                dao_id, proposal_id, token_id, daom__approved_proposers_015.aleo, dao_manager_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_dao_based_update_na_to_ap(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_dao_based_update_na_to_ap(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }


    async transition dao_based_update_na_to_na(
        public dao_id: field,
        public proposal_id: field,
        public token_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address
    ) -> Future {
        let dao_manager_params: NaDaoManagerParams = NaDaoManagerParams {
            dao_manager_updater: dao_manager_updater,
            voting_system_manager: voting_system_manager,
        };
        let dao_manager_params_hash: field = BHP256::hash_to_field(
            dao_manager_params
        );

        let update_dao_manager_future: Future =
            daomu__dao_based_na_015.aleo/update_dao_manager(
                dao_id, proposal_id, token_id, daom__no_approval_015.aleo, dao_manager_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_dao_based_update_na_to_na(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_dao_based_update_na_to_na(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }


    async transition dao_based_update_ap_to_ap(
        public dao_id: field,
        public proposal_id: field,
        public token_id: field,
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

        let update_dao_manager_future: Future =
            daomu__dao_based_ap_015.aleo/update_dao_manager(
                dao_id, token_id, proposal_id, daom__approved_proposers_015.aleo, dao_manager_params_hash
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_015.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_params
            );
        return finalize_dao_based_update_ap_to_ap(
            update_dao_manager_future,
            init_as_dao_manager_future,
        );
    }
    async function finalize_dao_based_update_ap_to_ap(
        f1: Future,
        f2: Future,
    ){
        f1.await();
        f2.await();
    }
}

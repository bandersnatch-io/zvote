import daom__approved_proposers_008.aleo;
import daom__no_approval_008.aleo;


program h__update_daom_helper_008.aleo {

    /*
    Update dao settings:
    */

    /*
    Fomer DAO manager: daom__approved_proposers_008.aleo
    New DAO manager: daom__no_approval_008.aleo
    */
    async transition update_ap_to_na(
        public dao_id: field,
        public dao_manager_updater: address,
        public voting_system_manager: address
    ) -> Future {
        let update_dao_manager_future: Future =
            daom__approved_proposers_008.aleo/update_dao_manager_as_signer(
                dao_id, daom__no_approval_008.aleo
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_008.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_updater,
                voting_system_manager
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
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public proposers_manager: address,
    ) -> Future {
        let update_dao_manager_future: Future =
            daom__no_approval_008.aleo/update_dao_manager_as_signer(
                dao_id, daom__approved_proposers_008.aleo
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_008.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_updater,
                voting_system_manager,
                proposers_manager
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
        public dao_manager_updater: address,
        public voting_system_manager: address
    ) -> Future {
        let update_dao_manager_future: Future =
            daom__no_approval_008.aleo/update_dao_manager_as_signer(
                dao_id, daom__no_approval_008.aleo
            );
        let init_as_dao_manager_future: Future =
            daom__no_approval_008.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_updater,
                voting_system_manager
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
        public dao_manager_updater: address,
        public voting_system_manager: address,
        public proposers_manager: address,
    ) -> Future {
        let update_dao_manager_future: Future =
            daom__approved_proposers_008.aleo/update_dao_manager_as_signer(
                dao_id, daom__approved_proposers_008.aleo
            );
        let init_as_dao_manager_future: Future =
            daom__approved_proposers_008.aleo/init_as_dao_manager(
                dao_id,
                dao_manager_updater,
                voting_system_manager,
                proposers_manager
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
}

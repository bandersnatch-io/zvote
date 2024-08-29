import multi_dao_support_program.aleo;


program daom__no_approval_required.aleo { // implements DaoManagers
    async transition create_proposal(
        public dao_id: field,
        public proposal_id: field,
        public content: field,
        public voting_system: address
    ) -> Future {
        let create_proposal_future: Future = 
            multi_dao_support_program.aleo/create_proposal(
                dao_id, proposal_id, content, voting_system
            );
        return finalize_create_proposal(
            create_proposal_future
        );
    }
    async function finalize_create_proposal(
        create_proposal_future: Future
    ) {
        create_proposal_future.await();
    }
}

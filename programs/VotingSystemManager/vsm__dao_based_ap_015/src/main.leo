import zvote_dao_registry_015.aleo;
import daom__approved_proposers_015.aleo;


program vsm__dao_based_ap_015.aleo { 
    struct ProposalKey {
        dao_id: field,
        proposal_id: field,
    }

    struct VotingSystemProposal {
        dao_id: field,
        proposal_id: field,
        voting_system: address,
        vs_params_hash: field,
        is_add: bool // or remove
    }
    mapping proposal_contents: field => VotingSystemProposal;
    // hash(ProposalKey) => VotingSystemProposal

    mapping executed_already: field => bool;
    // hash(ProposalKey) => has_been_executed_already

    async transition create_approve_proposal(
        public dao_id: field,
        public proposal_id: field,
        public proposal_params_hash: field,
        public proposed_voting_system: address,
        public proposed_vs_params_hash: field,
        public voting_system: address,
        public vs_params_hash: field,
        public is_add: bool
    ) -> Future {
        let create_proposal_future: Future =
            daom__approved_proposers_015.aleo/create_proposal(
                dao_id,
                proposal_id,
                self.address,
                proposal_params_hash,
                voting_system,
                vs_params_hash
            );

        let voting_system_proposal: VotingSystemProposal = VotingSystemProposal {
            dao_id: dao_id,
            proposal_id: proposal_id,
            voting_system: proposed_voting_system,
            vs_params_hash: proposed_vs_params_hash,
            is_add: is_add, // or remove
        };

        let proposal_key: ProposalKey = ProposalKey {
            dao_id: dao_id,
            proposal_id: proposal_id
        };
        let proposal_key_hash: field = BHP256::hash_to_field(proposal_key);
        return finalize_create_approve_proposal(
            proposal_key_hash,
            voting_system_proposal,
            create_proposal_future,
        );
    }
    async function finalize_create_approve_proposal(
        proposal_key_hash: field,
        voting_system_proposal: VotingSystemProposal,
        create_proposal_future: Future
    ) {
        create_proposal_future.await();
        let exists: bool = proposal_contents.contains(
            proposal_key_hash
        );
        assert(!exists);
        proposal_contents.set(proposal_key_hash, voting_system_proposal);
    }


    async transition add_voting_system(
        public dao_id: field,
        public proposal_id: field,
        public new_voting_system: address,
        public new_vs_params_hash: field
    ) -> Future {
        let approve_proposer_future: Future =
            daom__approved_proposers_015.aleo/add_voting_system(
                dao_id,
                new_voting_system,
                new_vs_params_hash
            );
        let proposal_key: ProposalKey = ProposalKey {
            dao_id: dao_id,
            proposal_id: proposal_id
        };
        let proposal_key_hash: field = BHP256::hash_to_field(proposal_key);
        return finalize_add_voting_system(
            proposal_key_hash,
            new_voting_system,
            new_vs_params_hash,
            approve_proposer_future,
        );
    }
    async function finalize_add_voting_system(
        proposal_key_hash: field,
        new_voting_system: address,
        new_vs_params_hash: field,
        approve_proposer_future: Future
    ){
        let proposer_proposal: VotingSystemProposal =
            proposal_contents.get(proposal_key_hash);
        assert_eq(proposer_proposal.voting_system, new_voting_system);
        assert_eq(proposer_proposal.vs_params_hash, new_vs_params_hash);
        assert(proposer_proposal.is_add);

        let vote_result: bool = zvote_dao_registry_015.aleo/results.get(
            proposal_key_hash
        ) as bool;
        assert(vote_result);

        assert(executed_already.contains(proposal_key_hash).not());
        executed_already.set(proposal_key_hash, true);

        approve_proposer_future.await();
    }



    async transition remove_voting_system(
        public dao_id: field,
        public proposal_id: field,
        public new_voting_system: address,
        public new_vs_params_hash: field
    ) -> Future {
        let approve_proposer_future: Future =
            daom__approved_proposers_015.aleo/remove_voting_system(
                dao_id,
                new_voting_system,
                new_vs_params_hash
            );
        let proposal_key: ProposalKey = ProposalKey {
            dao_id: dao_id,
            proposal_id: proposal_id
        };
        let proposal_key_hash: field = BHP256::hash_to_field(proposal_key);
        return finalize_remove_voting_system(
            proposal_key_hash,
            new_voting_system,
            new_vs_params_hash,
            approve_proposer_future,
        );
    }
    async function finalize_remove_voting_system(
        proposal_key_hash: field,
        new_voting_system: address,
        new_vs_params_hash: field,
        approve_proposer_future: Future
    ){
        let proposer_proposal: VotingSystemProposal =
            proposal_contents.get(proposal_key_hash);
        assert_eq(proposer_proposal.voting_system, new_voting_system);
        assert_eq(proposer_proposal.vs_params_hash, new_vs_params_hash);
        assert(!proposer_proposal.is_add);

        let vote_result: bool = zvote_dao_registry_015.aleo/results.get(
            proposal_key_hash
        ) as bool;
        assert(vote_result);

        assert(executed_already.contains(proposal_key_hash).not());
        executed_already.set(proposal_key_hash, true);

        approve_proposer_future.await();
    }
}

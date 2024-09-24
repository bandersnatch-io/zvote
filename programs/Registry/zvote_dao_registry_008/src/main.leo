program zvote_dao_registry_008.aleo {
    struct Dao {
        dao_id: field,
        token_id: field,
        dao_manager: address
    }

    struct Proposal {
        proposal_id: field,
        dao_id: field,
        content: field,
        voting_system: address,
        vs_params_hash: field
    }

    struct ProposalKey {
        dao_id: field,
        proposal_id: field,
    }

    struct VotingSystemKey {
        dao_id: field,
        voting_system: address
        vs_params_hash: field
    }

    mapping daos: field => Dao;
    // dao_id => dao
    mapping proposals: field => Proposal;
    // hash(ProposalKey) => Proposal
    mapping voting_systems: field => VotingSystemKey;
    // hash(VotingSystemKey) => VotingSystemKey
    mapping results: field => field;
    // hash(ProposalKey) => result

    async transition register_dao(
        public dao_id: field,
        public token_id: field,
        public dao_manager: address,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let dao: Dao = Dao {
            dao_id: dao_id,
            token_id: token_id,
            dao_manager: dao_manager
        };
        let voting_system_key: VotingSystemKey = VotingSystemKey{
            dao_id: dao_id,
            voting_system: voting_system,
            vs_params_hash: vs_params_hash
        };
        let voting_system_key_hash: field = BHP256::hash_to_field(
            voting_system_key
        );

        return finalize_register_dao(
            dao,
            voting_system_key,
            voting_system_key_hash
        );
    }
    async function finalize_register_dao(
        dao: Dao,
        voting_system_key: VotingSystemKey,
        voting_system_key_hash: field
    ) {
        let dao_exists: bool = daos.contains(dao.dao_id);
        assert(!dao_exists);
        daos.set(dao.dao_id, dao);

        voting_systems.set(voting_system_key_hash, voting_system_key);
    }


    async transition update_dao_manager(
        public dao_id: field,
        public new_dao_manager: address,
    ) -> Future {
        return finalize_update_dao_manager(
            dao_id, new_dao_manager, self.caller
        );
    }
    async function finalize_update_dao_manager(
        dao_id: field, new_dao_manager: address, caller: address
    ) {
        let dao: Dao = daos.get(dao_id);
        assert_eq(caller, dao.dao_manager);
        let updated_dao: Dao = Dao {
            dao_id: dao.dao_id,
            token_id: dao.token_id,
            dao_manager: new_dao_manager
        };
        daos.set(dao.dao_id, updated_dao);
    }

    async transition update_dao_token_id(
        public dao_id: field,
        public new_token_id: field,
    ) -> Future {
        return finalize_update_dao_token_id(
            dao_id, new_token_id, self.caller
        );
    }
    async function finalize_update_dao_token_id(
        dao_id: field, new_token_id: field, caller: address
    ) {
        let dao: Dao = daos.get(dao_id);
        assert_eq(caller, dao.dao_manager);
        let updated_dao: Dao = Dao {
            dao_id: dao.dao_id,
            token_id: new_token_id,
            dao_manager: dao.dao_manager
        };
        daos.set(dao.dao_id, updated_dao);
    }

    async transition add_voting_system(
        public dao_id: field,
        public new_voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let voting_system_key: VotingSystemKey = VotingSystemKey{
            dao_id: dao_id,
            voting_system: new_voting_system,
            vs_params_hash: vs_params_hash
        };
        let voting_system_key_hash: field = BHP256::hash_to_field(
            voting_system_key
        );
        return finalize_add_voting_system(
            voting_system_key, voting_system_key_hash, self.caller
        );
    }
    async function finalize_add_voting_system(
        voting_system_key: VotingSystemKey,
        voting_system_key_hash: field,
        caller: address
    ) {
        let dao: Dao = daos.get(voting_system_key.dao_id);
        assert_eq(caller, dao.dao_manager);

        voting_systems.set(voting_system_key_hash, voting_system_key);
    }


    async transition remove_voting_system(
        public dao_id: field,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let voting_system_key: VotingSystemKey = VotingSystemKey{
            dao_id: dao_id,
            voting_system: voting_system,
            vs_params_hash: vs_params_hash
        };
        let voting_system_key_hash: field = BHP256::hash_to_field(
            voting_system_key
        );
        return finalize_remove_voting_system(
            dao_id, voting_system_key_hash, self.caller
        );
    }
    async function finalize_remove_voting_system(
        dao_id: field,
        voting_system_key_hash: field,
        caller: address
    ) {
        let dao: Dao = daos.get(dao_id);
        assert_eq(caller, dao.dao_manager);
        voting_systems.remove(voting_system_key_hash);
    }


    async transition create_proposal(
        public dao_id: field,
        public proposal_id: field,
        public content: field,
        public voting_system: address,
        public vs_params_hash: field
    ) -> Future {
        let proposal_key: field = BHP256::hash_to_field(
            ProposalKey {
                dao_id: dao_id,
                proposal_id: proposal_id
            }
        );
        let proposal: Proposal = Proposal {
            proposal_id: proposal_id,
            dao_id: dao_id,
            content: content,
            voting_system: voting_system,
            vs_params_hash: vs_params_hash
        };

        let voting_system_key_hash: field = BHP256::hash_to_field(
            VotingSystemKey{
                dao_id: dao_id,
                voting_system: voting_system,
                vs_params_hash: vs_params_hash
            }
        );

        return finalize_create_proposal(
            proposal, proposal_key, voting_system_key_hash, self.caller
        );
    }
    async function finalize_create_proposal(
        proposal: Proposal,
        proposal_key: field,
        voting_system_key_hash: field,
        caller: address
    ) {
        let dao: Dao = daos.get(proposal.dao_id);
        assert_eq(caller, dao.dao_manager);

        assert(voting_systems.contains(voting_system_key_hash));

        let proposal_exists: bool = proposals.contains(proposal_key);
        assert(!proposal_exists);
        proposals.set(proposal_key, proposal);
    }
    

    async transition set_result(
        public dao_id: field,
        public proposal_id: field,
        public result: field,
    ) -> Future {
        let proposal_key: field = BHP256::hash_to_field(
            ProposalKey {
                dao_id: dao_id,
                proposal_id: proposal_id
            }
        );
        return finalize_set_result(proposal_key, result, self.caller);
    }
    async function finalize_set_result(
        proposal_key: field,
        result: field,
        caller: address
    ) {
        let proposal: Proposal = proposals.get(proposal_key);
        assert_eq(proposal.voting_system, caller);
        assert(results.contains(proposal_key).not());
        results.set(proposal_key, result);
    }
}

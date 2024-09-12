import multi_token_support_programv1.aleo;
import multi_dao_support_program.aleo;
import daom__approved_proposers_001.aleo;


program treasury__dao_based_001.aleo {
    const dao_id: field = 123field;
    
    struct HookedTransfer {
        proposal_id: field,
        token_id: field,
        recipient: address,
        amount: u128,
        triggering_result: field
    }

    mapping hooked_transfers: field => HookedTransfer;
    // proposal_id => HookedTransfer

    async transition hook_transfer_to_proposal(
        public proposal_id: field,
        public token_id: field,
        public recipient: address,
        public amount: u128,
        public triggering_result: field
    ) -> Future {
        let caller_proposer_key_hash: field = BHP256::hash_to_field(
            ProposerKey {
                dao_id: dao_id,
                proposer: self.caller,
            }
        );
        let proposal_key_hash: field = BHP256::hash_to_field(
            ProposalKey {
                dao_id: dao_id,
                proposal_id: proposal_id,
            }
        );
        let hooked_transfer: HookedTransfer = HookedTransfer {
            proposal_id: proposal_id,
            token_id: token_id,
            recipient: recipient,
            amount: amount,
            triggering_result: triggering_result
        };
        return finalize_hook_transfer_to_proposal(
            hooked_transfer,
            proposal_key_hash,
            caller_proposer_key_hash
        );
    }
    async function finalize_hook_transfer_to_proposal(
        hooked_transfer: HookedTransfer,
        proposal_key_hash: field,
        caller_proposer_key_hash: field
    ) {
        let allowed_caller: bool = 
            daom__approved_proposers_001.aleo/approved_proposers.contains(
                caller_proposer_key_hash
            );
        assert(allowed_caller);
        let proposal_exists: bool = 
            multi_dao_support_program.aleo/proposals.contains(
                proposal_key_hash
            );
        assert(!proposal_exists);
        hooked_transfers.set(
            hooked_transfer.proposal_id, hooked_transfer
        );
    }


    async transition transfer_public(
        public hooked_transfer: HookedTransfer,
    ) -> Future {
        let proposal_key_hash: field = BHP256::hash_to_field(
            ProposalKey {
                dao_id: dao_id,
                proposal_id: hooked_transfer.proposal_id,
            }
        );
        let transfer_future: Future = 
            multi_token_support_programv1.aleo/transfer_public(
                hooked_transfer.token_id,
                hooked_transfer.recipient,
                hooked_transfer.amount,
            );

        return finalize_transfer_public(
            hooked_transfer,
            proposal_key_hash,
            transfer_future
        );
    }
    async function finalize_transfer_public(
        hooked_transfer: HookedTransfer,
        proposal_key_hash: field,
        transfer_future: Future
    ) {
        transfer_future.await();
        let result: field = multi_dao_support_program.aleo/results.get(
            proposal_key_hash
        );
        assert_eq(result, hooked_transfer.triggering_result);

        let saved_hooked_transfer: HookedTransfer = hooked_transfers.get(
            hooked_transfer.proposal_id
        );
        assert_eq(hooked_transfer, saved_hooked_transfer);
    }
}

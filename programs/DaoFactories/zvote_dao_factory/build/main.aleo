import multi_dao_support_program.aleo;
import daom__approved_proposer_list.aleo;
import psm__dao_based.aleo;
import daomu__dao_based.aleo;
import vsm__dao_based.aleo;
program zvote_dao_factory.aleo;

struct Dao:
    dao_id as field;
    token_id as field;
    dao_manager as address;

struct Proposal:
    proposal_id as field;
    dao_id as field;
    content as field;
    voting_system as address;
    vs_params_hash as field;

struct VotingSystemKey:
    dao_id as field;
    voting_system as address;
    vs_params_hash as field;

struct ProposerProposal:
    dao_id as field;
    proposal_id as field;
    proposer as address;
    is_add as boolean;

struct DAOMUpdateProposal:
    dao_id as field;
    proposal_id as field;
    dao_manager as address;

struct VotingSystemProposal:
    dao_id as field;
    proposal_id as field;
    voting_system as address;
    vs_params_hash as field;
    is_add as boolean;



function register_dao:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.public;
    input r3 as field.public;
    call multi_dao_support_program.aleo/register_dao r0 r1 daom__approved_proposer_list.aleo into r4;
    call daom__approved_proposer_list.aleo/init_as_dao_manager r0 vsm__dao_based.aleo daomu__dao_based.aleo psm__dao_based.aleo into r5;
    call psm__dao_based.aleo/init_as_proposers_manager r0 into r6;
    call vsm__dao_based.aleo/init_as_voting_system_manager r0 r2 r3 into r7;
    async register_dao r4 r5 r6 r7 into r8;
    output r8 as zvote_dao_factory.aleo/register_dao.future;

finalize register_dao:
    input r0 as multi_dao_support_program.aleo/register_dao.future;
    input r1 as daom__approved_proposer_list.aleo/init_as_dao_manager.future;
    input r2 as psm__dao_based.aleo/init_as_proposers_manager.future;
    input r3 as vsm__dao_based.aleo/init_as_voting_system_manager.future;
    await r0;
    await r1;
    await r2;
    await r3;


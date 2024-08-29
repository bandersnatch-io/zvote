import credits.aleo;
import multi_token_support_program.aleo;
import multi_dao_support_program.aleo;
program no_approval_required_proposer.aleo;


struct TokenMetadata:
    token_id as field;
    name as u128;
    symbol as u128;
    decimals as u8;
    supply as u128;
    max_supply as u128;
    admin as address;
    external_authorization_required as boolean;
    external_authorization_party as address;

struct TokenOwner:
    account as address;
    token_id as field;


struct Dao:
    dao_id as field;
    token_id as field;
    admin as address;

struct Proposal:
    proposal_id as field;
    dao_id as field;
    voting_system as address;



function register_dao:
    input r0 as field.public;
    input r1 as field.public;
    call multi_dao_support_program.aleo/register_dao r0 r1 into r2;
    async register_dao r0 self.caller r2 into r3;
    output r3 as no_approval_required_proposer.aleo/register_dao.future;

finalize register_dao:
    input r0 as field.public;
    input r1 as address.public;
    input r2 as multi_dao_support_program.aleo/register_dao.future;
    await r2;




function create_proposal:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.public;
    call multi_dao_support_program.aleo/create_proposal r0 r1 r2 into r3;
    async create_proposal r3 into r4;
    output r4 as no_approval_required_proposer.aleo/create_proposal.future;

finalize create_proposal:
    input r0 as multi_dao_support_program.aleo/create_proposal.future;
    await r0;


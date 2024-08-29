import credits.aleo;
import multi_token_support_program.aleo;
import multi_dao_support_program.aleo;
program approved_list_proposer.aleo;


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
    voting_system as address;

struct Proposal:
    proposal_id as field;
    dao_id as field;
    content as field;

struct ProposerKey:
    dao_id as field;
    proposer as address;


mapping approved_list_admins:
	key as field.public;
	value as address.public;


mapping proposers:
	key as field.public;
	value as boolean.public;


function register_dao:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.public;
    call multi_dao_support_program.aleo/register_dao r0 r1 r2 into r3;
    async register_dao r0 self.caller r3 into r4;
    output r4 as approved_list_proposer.aleo/register_dao.future;

finalize register_dao:
    input r0 as field.public;
    input r1 as address.public;
    input r2 as multi_dao_support_program.aleo/register_dao.future;
    await r2;
    contains approved_list_admins[r0] into r3;
    not r3 into r4;
    assert.eq r4 true;
    set r1 into approved_list_admins[r0];




function create_proposal:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as field.public;
    cast r0 self.caller into r3 as ProposerKey;
    hash.bhp256 r3 into r4 as field;
    call multi_dao_support_program.aleo/create_proposal r0 r1 r2 into r5;
    async create_proposal r4 r5 into r6;
    output r6 as approved_list_proposer.aleo/create_proposal.future;

finalize create_proposal:
    input r0 as field.public;
    input r1 as multi_dao_support_program.aleo/create_proposal.future;
    get proposers[r0] into r2;
    assert.eq r2 true;
    await r1;




function approve_proposer:
    input r0 as field.private;
    input r1 as address.private;
    cast r0 r1 into r2 as ProposerKey;
    hash.bhp256 r2 into r3 as field;
    async approve_proposer r0 r3 self.caller into r4;
    output r4 as approved_list_proposer.aleo/approve_proposer.future;

finalize approve_proposer:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.public;
    get approved_list_admins[r0] into r3;
    assert.eq r3 r2;
    set true into proposers[r1];




function remove_proposer:
    input r0 as field.private;
    input r1 as address.private;
    cast r0 r1 into r2 as ProposerKey;
    hash.bhp256 r2 into r3 as field;
    async remove_proposer r0 r3 self.caller into r4;
    output r4 as approved_list_proposer.aleo/remove_proposer.future;

finalize remove_proposer:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.public;
    get approved_list_admins[r0] into r3;
    assert.eq r3 r2;
    remove proposers[r1];


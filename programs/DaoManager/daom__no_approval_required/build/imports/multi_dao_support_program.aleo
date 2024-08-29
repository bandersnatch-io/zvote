import credits.aleo;
import multi_token_support_program.aleo;
program multi_dao_support_program.aleo;


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

struct ProposalKey:
    dao_id as field;
    proposal_id as field;


mapping daos:
	key as field.public;
	value as Dao.public;


mapping proposals:
	key as field.public;
	value as Proposal.public;


mapping results:
	key as field.public;
	value as field.public;


function register_dao:
    input r0 as field.public;
    input r1 as field.public;
    cast r0 r1 self.caller into r2 as Dao;
    async register_dao r2 into r3;
    output r3 as multi_dao_support_program.aleo/register_dao.future;

finalize register_dao:
    input r0 as Dao.public;
    contains daos[r0.dao_id] into r1;
    not r1 into r2;
    assert.eq r2 true;
    set r0 into daos[r0.dao_id];




function update_admin:
    input r0 as field.public;
    input r1 as address.public;
    async update_admin r0 r1 self.caller into r2;
    output r2 as multi_dao_support_program.aleo/update_admin.future;

finalize update_admin:
    input r0 as field.public;
    input r1 as address.public;
    input r2 as address.public;
    get daos[r0] into r3;
    assert.eq r2 r3.admin;
    cast r3.dao_id r3.token_id r1 into r4 as Dao;
    set r3 into daos[r3.dao_id];




function create_proposal:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.public;
    cast r0 r1 into r3 as ProposalKey;
    hash.bhp256 r3 into r4 as field;
    cast r1 r0 r2 into r5 as Proposal;
    async create_proposal r5 r4 self.caller into r6;
    output r6 as multi_dao_support_program.aleo/create_proposal.future;

finalize create_proposal:
    input r0 as Proposal.public;
    input r1 as field.public;
    input r2 as address.public;
    get daos[r0.dao_id] into r3;
    assert.eq r2 r3.admin;
    contains proposals[r1] into r4;
    not r4 into r5;
    assert.eq r5 true;
    set r0 into proposals[r1];




function set_result:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as field.public;
    cast r0 r1 into r3 as ProposalKey;
    hash.bhp256 r3 into r4 as field;
    async set_result r4 r2 self.caller into r5;
    output r5 as multi_dao_support_program.aleo/set_result.future;

finalize set_result:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.public;
    get proposals[r0] into r3;
    assert.eq r3.voting_system r2;
    set r1 into results[r0];


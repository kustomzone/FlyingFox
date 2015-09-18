-module(create_account_tx).
-export([doit/3]).
-record(ca, {from = 0, nonce = 0, to = 0, pub = <<"">>, amount = 0}).
-record(acc, {balance = 0, nonce = 0, pub = 0}).
doit(Tx, ParentKey, Accounts) ->
    F = block_tree:account(Tx#ca.from, ParentKey, Accounts),
    To = block_tree:account(Tx#ca.to, ParentKey, Accounts),
    To = #acc{},%You can only fill space in the database that are empty.
    true = Tx#ca.to < constants:max_address(),
    OneUnder = block_tree:account(Tx#ca.to-1, ParentKey, Accounts),
    false = (OneUnder == #acc{}),%You can only fill a space if the space below you is already filled.
    NT = #acc{nonce = 0,
              pub = Tx#ca.pub,
              balance = Tx#ca.amount},
    NF = #acc{nonce = F#acc.nonce + 1,
              pub = F#acc.pub,
              balance = F#acc.balance - Tx#ca.amount - constants:create_account_fee()},
    Nonce = F#acc.nonce + 1,
    Nonce = Tx#ca.nonce,
    true = NT#acc.balance > 0,
    true = NF#acc.balance > 0,
    Accounts2 = dict:store(Tx#ca.to, NT, Accounts),
    dict:store(Tx#ca.from, NF, Accounts2).


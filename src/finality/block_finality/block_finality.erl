%Each block has both a height, and number. Blocks reference each other by height, and the database looks up blocks by height.
%Blocks only get appended to this once we are sure that block will be part of the blockchain.
%O(1) lookup time for blocks. Adding more blocks doesn't slow it down.
%this is made up of 3 modules. the block_pointers.db file uses 8 bytes for each block. The 8 bytes encodes the position and size of the block in block_dump.db file. block_finality.erl module gives an interface.
-module(block_finality).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2, read/1,append/1,top/0,top_block/0,test/0]).
-define(word, 8).
-record(block, {acc = 0, number = 0, hash = "", bond_size = 5000000, txs = [], power = 1, entropy = 0}).
-record(signed, {data="", sig="", sig2="", revealed=[]}).
init(ok) -> 
    H = top(),
    Genesis = #signed{data = #block{}},
    if
	H == 0 -> append_helper(packer:pack(Genesis));%store the genesis block into the database.
	true -> 0 = 0
    end,
    {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_call(_, _From, X) -> {reply, 0, X}.
handle_cast({append, X}, D) -> 
    append_helper(X),
    {noreply, D}.
append_helper(X) ->
    {A, B} = block_dump:write(X),
    N = <<A:38, B:26>>,%2**26 ~60 mb is how long blocks can be, 2**38 ~250 GB is how big the blockchain can be. 38+26=64 bits is 8 bytes, so I defined word as 8.
    block_pointers:append(N).
append(Block) -> gen_server:cast(?MODULE, {append, packer:pack(Block)}).
top() -> block_pointers:height().
read(N) -> 
    C = top(),
    true = N < C,
    <<A:38, B:26>> = block_pointers:read(N, 1),
    X = block_dump:read(A, B),
    packer:unpack(X).
top_block() -> read(top()-1).
test() ->
    X = [25],
    Y = {a, 1, <<"abc">>},
    append(X),
    append(Y),
    timer:sleep(5),
    X = read(top() - 2),
    Y = read(top() - 1),
    success.


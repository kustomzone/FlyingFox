-module(hash).
-export([doit/1,test/0]).

doit(S) -> crypto:hmac(sha256, packer:pack(S), "").

-record(p, {p = ""}).
test() -> 
    doit(123),
    doit(abc),
    doit([123]),
    doit([[[]]]),
    doit(#p{}).

-module(fractions).
-export([new/2,negate/1,add/2,subtract/2,multiply/2,divide/2,to_int/1,test/0, multiply_int/2, exponent/2]).
-record(f, {top = 0, bottom = 0}).
%lcd(A, B) when B>A -> lcd(B, A).
new(T,B) -> #f{top = T, bottom = B}.
negate(A) -> #f{top = -A#f.top, bottom = A#f.bottom}.
subtract(A, B) -> add(A, negate(B)).
add(A, B) -> simplify(#f{top = (A#f.top * B#f.bottom) + (A#f.bottom * B#f.top) , bottom = A#f.bottom * B#f.bottom}).
multiply(A, B) -> simplify(#f{top = A#f.top * B#f.top, bottom = A#f.bottom * B#f.bottom}).
divide(A, B) -> simplify(#f{top = A#f.top * B#f.bottom, bottom = A#f.bottom * B#f.top}).
to_int(A) -> A#f.top div A#f.bottom.
multiply_int(F, I) -> F#f.top * I div F#f.bottom.
simplify(F) -> simplify_lcd(simplify_size(F)).
simplify_lcd(F) ->
    L = lcd(F#f.top, F#f.bottom),
    #f{top = F#f.top div L, bottom = F#f.bottom div L}.
simplify_size(F) ->
    X = F#f.bottom div 340282366920938463463374607431768211456,
    Y = max(X, 1),
    #f{top = F#f.top div Y, bottom = F#f.bottom div Y}.
exponent(F, 0) -> #f{top = 1, bottom = 1};
exponent(F, 1) -> F;
exponent(F, N) when N rem 2 == 0 ->
    exponent(multiply(F, F), N div 2);
exponent(F, N) -> multiply(F, exponent(F, N - 1)).
    
lcd(A, 0) -> A;
lcd(A, B) -> lcd(B, A rem B).
test() ->
    A = new(1, 3),
    B = new(2, 5),
    C = multiply(A, B),
    C = new(2, 15),
    B = divide(C, A),
    9 = lcd(27, 9),
    5 = lcd(25, 15),
    success.
    

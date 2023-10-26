reduce([], X, X, _).
reduce([H|T], CurrentState, Result, Predicate) :-
    call(Predicate, H, CurrentState, NextState),
    reduce(T, NextState, Result, Predicate).

map(List, Result, Predicate) :-
    reduce(
        List, 
        [], 
        Result,
        [Value, State, NextState] >> (
            call(Predicate, Value, NewValue), 
            append(State, [NewValue], NextState)
        )
    ).

filter(List, Result, Predicate) :-
    reduce(
        List,
        [],
        Result,
        [Value, State, NextState] >> (
            call(Predicate, Value), append(State, [Value], NextState), !;
            NextState = State, !
        )
    ).

reverse(List, Result) :-
    reduce(
        List,
        [],
        Result,
        [Value, State, NextState]>>(
            append([Value], State, NextState)
        )
    ).

split(List, Separator, Result) :-
    reduce(
        List,
        [[]],
        ReversedResult,
        [Value, [H|T], NextState]>>(
            Value = Separator, append([[]], [H|T], NextState), !;
            append(H, [Value], NewH), append([NewH], T, NextState), !
        )
    ),
    reverse(ReversedResult, Result).

join(List, Result) :-
    reduce(
        List,
        [],
        Result,
        [Value, State, NextState]>>(
            append(State, Value, NextState)
        )
    ).
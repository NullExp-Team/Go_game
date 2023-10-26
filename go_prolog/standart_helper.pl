:- op(700, xfx, in).
:- op(701, xfx, at).
:- op(702, xfx, or).
:- op(704, fx, if).
:- op(703, xfx, then).
:- op(702, xfx, else).

if A then B else C :- A, B, !; C, !.
if A then B :- A, B, !; true.


A or B :- A; B.


% X? in Array at Index?
_ in [] at _ :- fail.
X in [H|_] at 0 :- not(X = H), fail.
X in [X|_] at 0 :- !.
X in [_|T] at Index :-
    not(var(Index)),
    NextIndex is Index - 1,
    X in T at NextIndex, !.
X in [_|T] at Index :-
    var(Index),
    X in T at NextIndex,
    Index is NextIndex + 1.



size([], 0).
size([_|T] , L) :- size(T,N), L is N+1.

statistics_sum([], [0, 0]).
statistics_sum([H|T], Sum) :-
    H = -,
    statistics_sum(T, Sum), !.
statistics_sum([[HC|HP]|T], [SumC, SumP]) :-
    statistics_sum(T, [NextSumC, NextSumP]),
    SumC is NextSumC + HC,
    SumP is NextSumP + HP.
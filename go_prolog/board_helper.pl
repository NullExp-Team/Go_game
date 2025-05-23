:- ['standart_helper'].

generate_empty_board(0, _, []) :- !.
generate_empty_board(Iterator, Size, [H|T]) :-
    (Iterator < Size or Iterator > Size * (Size - 1)) or (0 is Iterator mod Size or 1 is Iterator mod Size),
    H = #,
    NextIterator is Iterator - 1,
    generate_empty_board(NextIterator, Size, T), !.
generate_empty_board(Iterator, Size, [H|T]) :-
    H = -,
    NextIterator is Iterator - 1,
    generate_empty_board(NextIterator, Size, T).
generate_empty_board(Size, Board) :-
    CellsCount is Size * Size,
    generate_empty_board(CellsCount, Size, Board).


show_board([], _, _) :- !.
show_board([H|T], Size, Iterator) :-
    (0 is Iterator mod Size, write(H), write(' '), nl, !; write(H), write(' '), !),
    NextIterator is Iterator + 1,
    show_board(T, Size, NextIterator), !.
show_board(Board, Size) :-
    show_board(Board, Size, 1).

replace([_|T], 0, Value, [Value|T]).
replace([H|T], Index, Value, [H|T2]) :-
    NextIndex is Index - 1,
    replace(T, NextIndex, Value, T2), !.

block_regions(X, [], X).
block_regions(Board, [H|T], NewBoard) :-
    replace(Board, H, #, BlockedBoard),
    block_regions(BlockedBoard, T, NewBoard), !.

is_need_check_cell(Board, Size, Index, Value) :-
    LeftIndex is Index - 1,
    Value in Board at LeftIndex;

    RightIndex is Index + 1,
    Value in Board at RightIndex;

    TopIndex is Index - Size,
    Value in Board at TopIndex;

    BottomIndex is Index + Size,
    Value in Board at BottomIndex;

    TopLeftIndex is Index - Size - 1,
    Value in Board at TopLeftIndex;

    TopRightIndex is Index - Size + 1,
    Value in Board at TopRightIndex;

    BottomLeftIndex is Index + Size - 1,
    Value in Board at BottomLeftIndex;

    BottomRightIndex is Index + Size + 1,
    Value in Board at BottomRightIndex.
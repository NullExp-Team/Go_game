:- ['standart_helper'].
:- ['board_helper'].

is_value_board(Value, RegionValue) :-
    not(Value = RegionValue),
    not(Value = -).


is_cell_board(Board, CellIndex, RegionValue) :-
    notrace(CellValue in Board at CellIndex),
    is_value_board(CellValue, RegionValue).


is_cell_region(Board, Size, CellIndex, RegionValue, BlockedCells) :-
    notrace(RegionValue in Board at CellIndex),
    not(CellIndex in BlockedCells at _),

    append([CellIndex], BlockedCells, NextBlocked), !,
    LeftCellPosition is CellIndex - 1,
    (member(LeftCellPosition, BlockedCells) or is_cell_region(Board, Size, LeftCellPosition, RegionValue, NextBlocked)) or is_cell_board(Board, LeftCellPosition, RegionValue), !,
    
    RightCellPosition is CellIndex + 1,
    (member(RightCellPosition, BlockedCells) or is_cell_region(Board, Size, RightCellPosition, RegionValue, NextBlocked)) or is_cell_board(Board, RightCellPosition, RegionValue), !,

    TopCellPosition is CellIndex - Size,
    (member(TopCellPosition, BlockedCells) or is_cell_region(Board, Size, TopCellPosition, RegionValue, NextBlocked)) or is_cell_board(Board, TopCellPosition, RegionValue), !,

    BottomCellPosition is CellIndex + Size,
    (member(BottomCellPosition, BlockedCells) or is_cell_region(Board, Size, BottomCellPosition, RegionValue, NextBlocked)) or is_cell_board(Board, BottomCellPosition, RegionValue), !.


regions(_, Size, [], _, Index) :- 
    CellsCount is Size * Size,
    Index >= CellsCount, !.

regions(Board, Size, RegionCells, Value, Index) :-
    CellsCount is Size * Size,
    Index < CellsCount,
    is_cell_region(Board, Size, Index, Value, []),
    NextIndex is Index + 1,
    regions(Board, Size, NextRegions, Value, NextIndex),
    append([Index], NextRegions, RegionCells), !.

regions(Board, Size, RegionCells, Value, Index) :-
    CellsCount is Size * Size,
    Index < CellsCount,
    not(is_cell_region(Board, Size, Index, Value, [])),
    NextIndex is Index + 1,
    regions(Board, Size, RegionCells, Value, NextIndex), !.

regions(Board, Size, RegionCells, Value) :-
    regions(Board, Size, RegionCells, Value, 0).

player_regions(Board, Size, Regions) :-
    regions(Board, Size, Regions, o).

computer_regions(Board, Size, Regions) :-
    regions(Board, Size, Regions, x).

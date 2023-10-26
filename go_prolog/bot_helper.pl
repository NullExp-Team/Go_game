:- ['board_helper'].
:- ['standart_helper'].
:- ['region_helper'].



collect_steps_statistics(_, Size, _, [], Iterator) :-
    BoardCellsCount is Size * Size,
    Iterator >= BoardCellsCount, !.

collect_steps_statistics(Board, Size, Difficulty, Statistics, Iterator) :-
    not(- in Board at Iterator),
    NextIterator is Iterator + 1,
    collect_steps_statistics(Board, Size, Difficulty, NextStatistics, NextIterator),
    append([-], NextStatistics, Statistics), !.

collect_steps_statistics(Board, Size, Difficulty, Statistics, Iterator) :-
    is_need_check_cell(Board, Size, Iterator, x),
    calculate_statistics(Board, Size, Iterator, Difficulty, Stat, false),
    NextIterator is Iterator + 1,
    collect_steps_statistics(Board, Size, Difficulty, NextStatistics, NextIterator),
    append([Stat], NextStatistics, Statistics), !.

collect_steps_statistics(Board, Size, Difficulty, Statistics, Iterator) :-
    NextIterator is Iterator + 1,
    collect_steps_statistics(Board, Size, Difficulty, NextStatistics, NextIterator),
    append([-], NextStatistics, Statistics), !.

collect_steps_statistics(Board, Size, Difficulty, Statistics) :-
    collect_steps_statistics(Board, Size, Difficulty, Statistics, 0).




collect_steps_statistics_after_player_step(_, Size, _, [], Iterator) :-
    BoardCellsCount is Size * Size,
    Iterator >= BoardCellsCount, !.

collect_steps_statistics_after_player_step(Board, Size, Difficulty, Statistics, Iterator) :-
    not(- in Board at Iterator),
    NextIterator is Iterator + 1,
    collect_steps_statistics_after_player_step(Board, Size, Difficulty, NextStatistics, NextIterator),
    append([-], NextStatistics, Statistics), !.

collect_steps_statistics_after_player_step(Board, Size, Difficulty, Statistics, Iterator) :-
    is_need_check_cell(Board, Size, Iterator, o),
    calculate_statistics(Board, Size, Iterator, Difficulty, Stat, true),
    NextIterator is Iterator + 1,
    collect_steps_statistics_after_player_step(Board, Size, Difficulty, NextStatistics, NextIterator),
    append([Stat], NextStatistics, Statistics), !.

collect_steps_statistics_after_player_step(Board, Size, Difficulty, Statistics, Iterator) :-
    NextIterator is Iterator + 1,
    collect_steps_statistics_after_player_step(Board, Size, Difficulty, NextStatistics, NextIterator),
    append([-], NextStatistics, Statistics), !.

collect_steps_statistics_after_player_step(Board, Size, Difficulty, Statistic) :-
    collect_steps_statistics_after_player_step(Board, Size, Difficulty, Statistic, 0).



calculate_statistics(_, _, _, 0, [0,0], _) :- !.
calculate_statistics(Board, Size, Step, Difficulty, Statistic, IsPlayerMove) :-
    not(IsPlayerMove),
    replace(Board, Step, o, BoardAfterStep),
    computer_regions(BoardAfterStep, Size, CopmuterRegions),
    block_regions(BoardAfterStep, CopmuterRegions, BoardAfterComputerRegionsBlock),
    player_regions(BoardAfterComputerRegionsBlock, Size, PlayerRegions),
    block_regions(BoardAfterComputerRegionsBlock, PlayerRegions, BoardAfterPlayerRegionsBlock),
    size(CopmuterRegions, PlusPoints),
    size(PlayerRegions, MinusPoints),

    NextDifficulty is Difficulty - 1,
    collect_steps_statistics_after_player_step(BoardAfterPlayerRegionsBlock, Size, NextDifficulty, NextStatistics), !,

    statistics_sum(NextStatistics, [SumC, SumP]),

    ValueC is PlusPoints + SumC,
    ValueP is MinusPoints + SumP,
    Statistic = [ValueC, ValueP], !.

calculate_statistics(Board, Size, Step, Difficulty, Statistic, IsPlayerMove) :-
    IsPlayerMove,

    replace(Board, Step, x, BoardAfterStep),
    player_regions(BoardAfterStep, Size, PlayerRegions),
    block_regions(BoardAfterStep, PlayerRegions, BoardAfterPlayerRegionsBlock),
    computer_regions(BoardAfterPlayerRegionsBlock, Size, CopmuterRegions),
    block_regions(BoardAfterPlayerRegionsBlock, CopmuterRegions, BoardAfterComputerRegionsBlock),
    size(CopmuterRegions, PlusPoints),
    size(PlayerRegions, MinusPoints),

    NextDifficulty is Difficulty - 1,
    collect_steps_statistics(BoardAfterComputerRegionsBlock, Size, NextDifficulty, NextStatistics), !,

    statistics_sum(NextStatistics, [SumC, SumP]),

    ValueC is PlusPoints + SumC,
    ValueP is MinusPoints + SumP,
    Statistic = [ValueC, ValueP], !.

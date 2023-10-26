:- ['standart_helper'].
:- ['board_helper'].
:- ['region_helper'].
:- ['bot_helper'].
:- ['functional'].

game(Board, Size, Difficulty, PlayerScore, BotScore, PlayerStep, NextBoard, NextPlayerScore, NextBotScore) :-
    replace(Board, PlayerStep, x, BoardAfterPlayerStep),
    player_regions(BoardAfterPlayerStep, Size, FirstPlayerRegions),
    block_regions(BoardAfterPlayerStep, FirstPlayerRegions, BoardAfterFirstPlayerRegionBlock),
    computer_regions(BoardAfterFirstPlayerRegionBlock, Size, FirstBotRegions),
    block_regions(BoardAfterFirstPlayerRegionBlock, FirstBotRegions, BoardAfterPreset),

    bot_step(BoardAfterPreset, Size, Difficulty, BotStep),

    replace(BoardAfterPreset, BotStep, o, BoardAfterBotStep),
    computer_regions(BoardAfterBotStep, Size, SecondBotRegions),
    block_regions(BoardAfterBotStep, SecondBotRegions, BoardAfterFinalBotRegionBlock),
    player_regions(BoardAfterFinalBotRegionBlock, Size, SecondPlayerRegions),
    block_regions(BoardAfterFinalBotRegionBlock, SecondPlayerRegions, NextBoard),

    size(FirstPlayerRegions, FirstPlayerPoints),
    size(SecondPlayerRegions, SecondPlayerPoints),
    
    NextPlayerScore is PlayerScore + FirstPlayerPoints + SecondPlayerPoints,

    size(FirstBotRegions, FirstBotPoints),
    size(SecondBotRegions, SecondBotPoints),
    
    NextBotScore is BotScore + FirstBotPoints + SecondBotPoints, !.


bot_step(Board, Size, Difficulty, Step) :-
    collect_steps_statistics(Board, Size, Difficulty, Statistics),
    filter(Statistics, FilteredStatistics, [X]>>(not(X = -))),
    map(FilteredStatistics, MapedStatistics, [X, Y]>>([Y,Z] is X, Y)),
    max_list(MapedStatistics, Max),
    show_board(Statistics,Size), nl,
    write(Max), nl,
    [Max,_] in Statistics at Step,
    write(Step), nl.
:- ['standart_helper'].
:- ['board_helper'].
:- ['region_helper'].
:- ['bot_helper'].

bot_step(Board, Size, Difficulty, Step) :-
    collect_steps_statistics(Board, Size, Difficulty, Statistics),
    maxlist(Statistics, Max),
    Max in Statistics at Step.
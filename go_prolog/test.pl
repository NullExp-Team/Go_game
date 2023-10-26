:- ['go_game'].

load_board(Board) :-
    open('board.txt', read, S),
    read(S, Board), !.


bot_play(PlayerStepX, PlayerStepY, NewBoard) :-
    statistics(runtime, [Start|_]),
    PlayerStep is 7 + PlayerStepY * 7 + PlayerStepX + 1,
    load_board(Board),
    game(Board, 7, 4, 0, 0, PlayerStep, NewBoard, _, _),
    show_board(NewBoard, 7),
    statistics(runtime, [Stop|_]),
    Runtime is Stop - Start,
    write('step time: '), write(Runtime), nl, !.
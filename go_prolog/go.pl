:- ['standart_helper'].
:- ['region_helper'].
:- ['board_helper'].

% 'x' - фишка пользователя
% 'o' - фишка компьютера
% '-' - пустая клетка
% '#' - заблокированная клетка

:- dynamic(game/4).

new_game(BoardSize) :-
    generate_board(BoardSize, CleanBoard),
    (
        game(Board, Size, PlayerScore, ComputerScore), 
        retract(game(Board, Size, PlayerScore, ComputerScore)),
        assertz(game(CleanBoard, BoardSize, 0, 0));
        assertz(game(CleanBoard, BoardSize, 0, 0))
    ).
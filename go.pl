:- dynamic(state/1).

bot_step(Board, Size, NewBoard) :-
    move_player2(Board, 0, 0, [], Size).

play(Size) :-
    BoardSize is Size * Size,
    makeBoard(BoardSize, Board),
    play(Size, Board).

play(Size, Board) :-
    nl,
    write('******************'), nl,
	  write('* Prolog GO game *'), nl,
	  write('*******Board********'), nl, nl,
          game(Size, Board).

game(Size, Board):-
    nl,write('Single player or Multiplayer? (s or m)'),nl,
    read(Game),nl,
    ( 
        Game \= s, Game \= m,!,
        write('Error : Not valid Game. Try again (s or m)'),nl,
        game;
        ask_player(Game,Size, Board)
    ).

ask_player(Game, Size, Board):-
    nl,write('Player 1? (o or x)'),nl,
    read(Player_1),nl,
    ( Player_1 \= o, Player_1 \= x, !,
      write('Error : not a valid color !'), nl,
      ask_player(Game, Size);
      show_board(Board, Size),nl,
      S=0,
      S1=0,
      Invalid_move=[],
      move_player1(Board,S,S1,Invalid_move, Size)
    ).

makeBoard(0, []).
makeBoard(Size, [H|T]) :-
    H = -,
    NewSize is Size-1,
    makeBoard(NewSize, T).

move_player1(Board,S,S1,Invalid_move, Size):-
    write('Player 1 Move? (x)'),nl,
    read(Pos),nl,
    Player = x,
    replace(Board, Pos,Player, NextBoard),
    retract(state(Board)),
    assertz(state(NextBoard)),
    show_board(NextBoard, Size),
    write('Player X :'),write(S),nl,write('Player O :'),write(S1),nl,
    Opponent=o,
    Counter=0,
    check_winpose(Player,Opponent,NextBoard,Counter,S,S1,Invalid_move, Size).

move_player2(NextBoard,S,S1,Invalid_move, Size):-
      Player = o,
      Opponent=x,
      Counter=0,
      check_winpose_1(Player,Opponent,NextBoard,Counter,S,S1,Invalid_move, Size).

check_winpose(Player,Opponent,Board,Counter,S,S1,Invalid_move, Size):-
    BoardSize is Size * Size,
    Counter < BoardSize,
    nth0(Counter,Board,Y),
    Opp_list=[],
    Neighbour=[],
    winpose(Y,Player,Opponent,Board,Counter,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    Counter1 is Counter+1,
    check_winpose(Player,Opponent,Board,Counter1,S,S1,Invalid_move, Size);
    Opponent = o, move_player2(Board,S,S1,Invalid_move, Size);
    Opponent = x, move_player1(Board,S,S1,Invalid_move, Size).


winpose(Y,Player, Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    Y= Opponent,
    collect_Neighbour(Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    write('End neighbour list');
    Counter1 is Pos+1,
    check_winpose(Player,Opponent,Board,Counter1,S,S1,Invalid_move, Size),write('miss'),nl.

collect_Neighbour(Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size):-

    member_chk(Pos,Opp_list,A),
    A=false,
    member_chk(Pos,Neighbour,Z),

    Z=false,
    add(Pos,Opp_list,New_Opp_list),

    NU is Pos-Size,
    limit_neighbour(NU,Neighbour, New_neighbour1, Size),
    delete(New_neighbour1,Pos,Neb_List1),

    ND is Pos+Size,
    limit_neighbour(ND,Neb_List1, New_neighbour2, Size),
    delete(New_neighbour2,Pos,Neb_List2),

    NL is Pos-1,
    limit_neighbour2(Pos,NL,Neb_List2, New_neighbour3, Size),
    delete(New_neighbour3,Pos,Neb_List3),

    NR is Pos+1,
    limit_neighbour1(Pos,NR,Neb_List3, New_neighbour4, Size),
    delete(New_neighbour4,Pos,Neb_List),

    Counter=0,!,
    check_opp(Pos,Opponent,Board,New_Opp_list,Neb_List,Counter,S,S1,Invalid_move, Size);
    check_neighbour_list(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size).

check_opp(Pos,Opponent,Board,Opp_list,Neighbour,Counter,S,S1,Invalid_move, Size):-
    BoardSize is Size * Size,
    Counter<BoardSize,
    member_chk(Counter,Neighbour,X),
    X = true,
    nth0(Counter,Board,Y),
    is_mem(Y,Opponent,Board,Counter,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    Counter1 is Counter+1,
    check_opp(Pos,Opponent,Board,Opp_list,Neighbour,Counter1,S,S1,Invalid_move, Size);
        BoardSize is Size * Size,
    Counter<BoardSize,
    Counter1 is Counter+1,
    check_opp(Pos,Opponent,Board,Opp_list,Neighbour,Counter1,S,S1,Invalid_move, Size);
        BoardSize is Size * Size,
    Counter=BoardSize,
    check_neighbour_list(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size).


check_neighbour_list(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
   len(Opp_list,Len),
   Length is Len-1,
    nth0(Length,Opp_list,D),
   delete(Neighbour,D,Neb_List),
    Counter=0,
    len(Neb_List,Len1),
    is_surounded_by_player(Counter,Len1,Opponent,Board,Opp_list,Neb_List,S,S1,Invalid_move, Size).

is_surounded_by_player(Counter,Len ,Opponent,Board,Opp_list,Neb_List,S,S1,Invalid_move, Size):-
    Counter<Len,
    nth0(Counter,Neb_List,M),
    nth0(M,Board,Pos),
    Pos \= Opponent,
    Pos \= -,
    Counter_1 is Counter+1,
    is_surounded_by_player(Counter_1,Len ,Opponent,Board,Opp_list,Neb_List,S,S1,Invalid_move, Size);

    Counter=Len,
    Counter2=0,
    len(Opp_list,Len1),
    remove_opponent(Counter2,Len1 ,Opponent,Board,Opp_list,Neb_List,S,S1,Invalid_move, Size).

remove_opponent(Counter,Len1 ,Opponent,Board,Opp_list,Neb_List,S,S1,Invalid_move, Size):-
    Counter<Len1,
    nth0(Counter,Opp_list,M),
    L1=[M],
    append(L1,Invalid_move,Invalid_move_1),
    replace(Board,M,-, NextBoard),
    Counter1 is Counter+1,
    remove_opponent(Counter1,Len1 ,Opponent,NextBoard,Opp_list,Neb_List,S,S1,Invalid_move_1, Size);
    Counter=Len1,
    update_board(Opponent,Board,S,S1,Invalid_move, Size).

update_board(Opponent,Board,X,X2,Invalid_move, Size):-
    nl,show_board(Board, Size),
    Opponent = o,incr(X, X1),write('Player X :'),write(X1),nl,write('Player O :'),write(X2),nl, move_player2(Board,X1,X2,Invalid_move, Size);
    Opponent = x,incr(X2, X3),write('Player X :'),write(X),nl,write('Player O :'),write(X3),nl, move_player1(Board,X,X3,Invalid_move, Size).

incr(X, X1) :-
    X1 is X+1
    .
is_mem(Y,Opponent,Board,Mem,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    Y=Opponent,
    delete(Neighbour,Mem,Neb_List),
    collect_Neighbour(Opponent,Board,Mem,Opp_list,Neb_List,S,S1,Invalid_move, Size).


member_chk(Pos,List,X):-
    member(Pos,List),
    X= true,!;
    X= false.

add(X,List,[X|List]).

len([], LenResult):-
    LenResult is 0.

len([_|Y], LenResult):-
    len(Y, L),
    LenResult is L + 1.

limit_neighbour(N,Neighbour, New_neighbour, Size):-
    N> -1,
    BoardSize is Size * Size,
    N<BoardSize,
    L=[N],
    append(L,Neighbour, New_neighbour);New_neighbour=Neighbour.

make_limiting(Size, [], Now) :-
    BoardSize is Size * Size,
    !, Now > BoardSize.
make_limiting(Size, [H|T], Now) :-
    H is Now,
    NewNow is Now + Size,
    make_limiting(Size, T, NewNow).
make_limiting(Size, List) :-
    Start is Size - 1,
    make_limiting(Size, List, Start).

make_limiting2(Size, [], Now) :-
    BoardSize is Size * Size,
    !, Now is BoardSize.
make_limiting2(Size, [H|T], Now) :-
    H is Now,
    NewNow is Now + Size,
    make_limiting2(Size, T, NewNow).
make_limiting2(Size, List) :-
    Start is 0,
    make_limiting2(Size, List, Start).

limit_neighbour1(Pos,N,Neighbour, New_neighbour, Size):-
    make_limiting(Size, List),
    memberchk(Pos,List),
    New_neighbour=Neighbour;

    N> -1,
    BoardSize is Size * Size,
    N<BoardSize,
    L=[N],
    append(L,Neighbour, New_neighbour).

limit_neighbour2(Pos,N,Neighbour, New_neighbour, Size):-
    make_limiting2(Size, List),
    memberchk(Pos,List),
    New_neighbour=Neighbour;

    N> -1,
    BoardSize is Size * Size,
    N<BoardSize,
    L=[N],
    append(L,Neighbour, New_neighbour).


replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]):- I > -1, NI is I-1, replace(T, NI, X, R), !.


show_board([], Size, Counter).
show_board([H|T], Size, Counter) :-
    show2(H),!,
    (
        Counter is Size, NewCounter is 1, nl; 
        NewCounter is Counter+1
    ),!,
    show_board(T, Size, NewCounter).
show_board(List, Size):-
    show_board(List, Size, 1).


% show2(+Term)
% Write the term to current outupt
% Replace 0 by ' '.
show2(X) :-
    X = -, !,
    write('- ').
show2(X) :-
    write(X),write(' ').


check_winpose_1(Player,Opponent,Board,Counter,S,S1,Invalid_move, Size):-
    BoardSize is Size * Size,
    Counter < BoardSize,
    nth0(Counter,Board,Y),
    Opp_list=[],
    Neighbour=[],
    winpose_1(Y,Player,Opponent,Board,Counter,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    Counter1 is Counter+1,
    check_winpose_1(Player,Opponent,Board,Counter1,S,S1,Invalid_move, Size);
    Counter=0,
    check_winpose_2(Player,Opponent,Board,Counter,S,S1,Invalid_move, Size).


winpose_1(Y,Player, Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    Y= Opponent,
    collect_Neighbour_1(Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    write('End neighbour list');
    Counter1 is Pos+1,
    check_winpose_1(Player,Opponent,Board,Counter1,S,S1,Invalid_move, Size),write('miss'),nl.

collect_Neighbour_1(Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    member_chk(Pos,Opp_list,A),

    A=false,
    member_chk(Pos,Neighbour,Z),
    Z=false,
    add(Pos,Opp_list,New_Opp_list),

    NU is Pos-Size,
    limit_neighbour(NU,Neighbour, New_neighbour1, Size),
    delete(New_neighbour1,Pos,Neb_List1),
    ND is Pos+Size,

    limit_neighbour(ND,Neb_List1, New_neighbour2, Size),
    delete(New_neighbour2,Pos,Neb_List2),

    NL is Pos-1,
    limit_neighbour2(Pos,NL,Neb_List2, New_neighbour3, Size),
    delete(New_neighbour3,Pos,Neb_List3),
    NR is Pos+1,

    limit_neighbour1(Pos,NR,Neb_List3, New_neighbour4, Size),
    delete(New_neighbour4,Pos,Neb_List),

    Counter=0,!,
    check_opp_1(Pos,Opponent,Board,New_Opp_list,Neb_List,Counter,S,S1,Invalid_move, Size);

    check_neighbour_list_1(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size).

check_opp_1(Pos,Opponent,Board,Opp_list,Neighbour,Counter,S,S1,Invalid_move, Size):-
    BoardSize is Size * Size,
    Counter<BoardSize,

    member_chk(Counter,Neighbour,X),
    X = true,
    nth0(Counter,Board,Y),
    is_mem_1(Y,Opponent,Board,Counter,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    Counter1 is Counter+1,
    check_opp_1(Pos,Opponent,Board,Opp_list,Neighbour,Counter1,S,S1,Invalid_move, Size);
    BoardSize is Size * Size,
    Counter<BoardSize,
   Counter1 is Counter+1,
    check_opp_1(Pos,Opponent,Board,Opp_list,Neighbour,Counter1,S,S1,Invalid_move, Size);
        BoardSize is Size * Size,
    Counter=BoardSize,
    check_neighbour_list_1(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size).


is_mem_1(Y,Opponent,Board,Mem,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    Y=Opponent,
    delete(Neighbour,Mem,Neb_List),
    collect_Neighbour_1(Opponent,Board,Mem,Opp_list,Neb_List,S,S1,Invalid_move, Size).

check_neighbour_list_1(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
   len(Opp_list,Len),
   Length is Len-1,
    nth0(Length,Opp_list,D),
   delete(Neighbour,D,Neb_List),
    Counter=0,
    len(Neb_List,Len1),
    New_list=[],
    is_surounded_by_player_1(Counter,Len1,Opponent,Board,Opp_list,Neb_List,S,S1,New_list,Invalid_move, Size).

is_surounded_by_player_1(Counter,Len ,Opponent,Board,Opp_list,Neb_List,S,S1,New_list,Invalid_move, Size):-
    Counter<Len,
    nth0(Counter,Neb_List,M),
    nth0(M,Board,Pos),
    Pos \= Opponent,
    Pos = -,
    L=[M],
    append(L,New_list,Last_list),
    Counter_1 is Counter+1,
    !,
    is_surounded_by_player_1(Counter_1,Len ,Opponent,Board,Opp_list,Neb_List,S,S1,Last_list,Invalid_move, Size);
    Counter<Len,
    Counter_1 is Counter+1,
    !,
    is_surounded_by_player_1(Counter_1,Len ,Opponent,Board,Opp_list,Neb_List,S,S1,New_list,Invalid_move, Size);
    len(New_list,Len1),
    Len1=1,
    nth0(0,Neb_List,F1),
    nth0(F1,Board,F2),
    F2 \= x,

    nth0(1,Neb_List,F3),
    nth0(F3,Board,F4),
    F4 \= x,

    nth0(0,New_list,First_mem),
    member_chk(First_mem,Invalid_move,X),!,
    X=false,
    move_player_2(Board,S,S1,First_mem,Invalid_move, Size).

move_player_2(NextBoard,S,S1,Pos,Invalid_move, Size):-
    write('Player 2 Move? Computer (o)'),nl,
    write(Pos),nl,
    Player = o,
    replace(NextBoard, Pos, Player, Board),
    retract(state(NextBoard)),
    assertz(state(Board)),
    show_board(Board, Size),
    write('Player X :'),write(S),nl,write('Player O :'),write(S1),nl,
    Opponent=x,
    Counter=0,
    check_winpose(Player,Opponent,Board,Counter,S,S1,Invalid_move, Size).

check_winpose_2(Player,Opponent,Board,Counter,S,S1,Invalid_move, Size):-
    BoardSize is Size * Size,
    Counter < BoardSize,
    nth0(Counter,Board,Y),
    Opp_list=[],
    Neighbour=[],
    winpose_2(Y,Player,Opponent,Board,Counter,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    Counter1 is Counter+1,
    check_winpose_2(Player,Opponent,Board,Counter1,S,S1,Invalid_move, Size).

winpose_2(Y,Player, Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    Y= Opponent,
    collect_Neighbour_2(Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    write('End neighbour list');
    Counter1 is Pos+1,
    check_winpose_2(Player,Opponent,Board,Counter1,S,S1,Invalid_move, Size),write('miss'),nl.

collect_Neighbour_2(Opponent,Board,Pos,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    member_chk(Pos,Opp_list,A),
    A=false,
    member_chk(Pos,Neighbour,Z),
    Z=false,
    add(Pos,Opp_list,New_Opp_list),
    NU is Pos-Size,
    limit_neighbour(NU,Neighbour, New_neighbour1, Size),
    delete(New_neighbour1,Pos,Neb_List1),
    ND is Pos+Size,
    limit_neighbour(ND,Neb_List1, New_neighbour2, Size),
    delete(New_neighbour2,Pos,Neb_List2),
    NL is Pos-1,
    limit_neighbour2(Pos,NL,Neb_List2, New_neighbour3, Size),
    delete(New_neighbour3,Pos,Neb_List3),
    NR is Pos+1,

    limit_neighbour1(Pos,NR,Neb_List3, New_neighbour4, Size),
    delete(New_neighbour4,Pos,Neb_List),

    Counter=0,!,
    check_opp_2(Pos,Opponent,Board,New_Opp_list,Neb_List,Counter,S,S1,Invalid_move, Size);
    check_neighbour_list_2(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size).

check_opp_2(Pos,Opponent,Board,Opp_list,Neighbour,Counter,S,S1,Invalid_move, Size):-
    BoardSize is Size * Size,
    Counter<BoardSize,

    member_chk(Counter,Neighbour,X),
    X = true,
    nth0(Counter,Board,Y),

    is_mem_2(Y,Opponent,Board,Counter,Opp_list,Neighbour,S,S1,Invalid_move, Size),
    Counter1 is Counter+1,
    check_opp_2(Pos,Opponent,Board,Opp_list,Neighbour,Counter1,S,S1,Invalid_move, Size);
        BoardSize is Size * Size,
    Counter<BoardSize,
    Counter1 is Counter+1,
    check_opp_2(Pos,Opponent,Board,Opp_list,Neighbour,Counter1,S,S1,Invalid_move, Size);
        BoardSize is Size * Size,
    Counter=BoardSize,
    check_neighbour_list_2(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size).

is_mem_2(Y,Opponent,Board,Mem,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    Y=Opponent,
    delete(Neighbour,Mem,Neb_List),
    collect_Neighbour_2(Opponent,Board,Mem,Opp_list,Neb_List,S,S1,Invalid_move, Size).

check_neighbour_list_2(Opponent,Board,Opp_list,Neighbour,S,S1,Invalid_move, Size):-
    len(Opp_list,Len),
    Length is Len-1,
    nth0(Length,Opp_list,D),
    delete(Neighbour,D,Neb_List),
    Counter=0,
    len(Neb_List,Len1),
    New_list=[],
    is_surounded_by_player_2(Counter,Len1,Opponent,Board,Opp_list,Neb_List,S,S1,New_list,Invalid_move, Size).

is_surounded_by_player_2(Counter,Len ,Opponent,Board,Opp_list,Neb_List,S,S1,New_list,Invalid_move, Size):-
    Counter<Len,
    nth0(Counter,Neb_List,M),
    nth0(M,Board,Pos),
    Pos \= Opponent,
    Pos = -,
    L=[M],
    append(L,New_list,Last_list),
    Counter_1 is Counter+1,

    is_surounded_by_player_2(Counter_1,Len ,Opponent,Board,Opp_list,Neb_List,S,S1,Last_list,Invalid_move, Size);
    nth0(0,New_list,First_mem),
    member_chk(First_mem,Invalid_move,X),!,
    X=false,
    move_player_2(Board,S,S1,First_mem,Invalid_move, Size).


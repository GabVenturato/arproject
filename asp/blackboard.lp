value(1..k).
tilename(1..n).
%tile(N,L,R) :- tilename(N), value(L), value(R). input check not necessary

coord(1..h).
%board(X,Y) :- coord(X), coord(Y).

% input: k, n, h, tile(n,l,r)

%%
% ON BOARD
% the tile can be "on board" horizontally or vertically
% horizontal
placed_on(T,X+1,Y) :-
    tilename(T),
    coord(1), coord(Y), coord(X+1),
    placed_on(T,X,Y).

% vertical
placed_on(T,X,Y+1) :-
    tilename(T),
    coord(1), coord(Y), coord(Y+1),
    placed_on(T,X,Y).

placed(T) :- placed_on(T,_,_).

%0 { placed(T) } 1 :- tilename(T).
0 {placed_on(T,X,Y) : coord(X), coord(Y) } 2 :- tilename(T).
{placed_on(T,X,Y) : coord(X), coord(Y) } != 1 :- tilename(T).
#show placed_on/3.
%#show placed/1.

%* -----------------------------------------------------------------------------
% horizontal
onboard_h(N,X1,Y1,X2,Y2) :-
    tilename(N),
    coord(X1), coord(Y1), coord(X2), coord(Y2),
    X2 == X1+1,
    Y1 == Y2.

% vertical
onboard_v(N,X1,Y1,X2,Y2) :-
    tilename(N),
    coord(X1), coord(Y1), coord(X2), coord(Y2),
    X1 == X2,
    Y2 == Y1+1.

board(X,Y,N) :- on
----------------------------------------------------------------------------- *%

%* -----------------------------------------------------------------------------
0 { b(N,X1,Y1,X2,Y2) : coord(X1), coord(Y1), coord(X2), coord(Y2) } 1 :-
    tilename(N).
0 { b(N,X1,Y1,X2,Y2) : tilename(N) } 1 :-
    coord(X1), coord(Y1), coord(X2), coord(Y2).
good_placed(X1,Y1,X2,Y2) :- 
:- b(N,X1,Y1,X2,Y2), 
    |X1-X2| > 0,
    |Y1-Y2| > 0, 
    |X1-X2| + |Y1-Y2| = 0.
#show b/5.
----------------------------------------------------------------------------- *%

%onboard(N,X,Y) :- onboard_h(N,X,Y,_,_).
%onboard(N,X,Y) :- onboard_v(N,X,Y,_,_).

%* -----------------------------------------------------------------------------
% NEXT
% a tile can be next to another (vercially: cases 1 or 3)
next(N1,N2) :-
    tile(N1,_,R), tile(N2,L,_),
    R == L,
    onboard(N1,_,_,X1,Y1),
    onboard(N2,X2,Y2,_,_),
    X1 == X2,
    |Y1 - Y2| == 1,
    N1 != N2. % otherwise a tile can be next to itself

% a tile can be next to another (horizontally: cases 1 or 3)
next(N1,N2) :-
    tile(N1,_,R), tile(N2,L,_),
    R == L,
    onboard(N1,_,_,X1,Y1),
    onboard(N2,X2,Y2,_,_),
    Y1 == Y2,
    |X1 - X2| == 1,
    N1 != N2. % otherwise a tile can be next to itself
----------------------------------------------------------------------------- *%

%% Constraints
% each tile can be in at most one position
%0 { onboard(N,X1,Y1,X2,Y2) : tilename(N) } 1 :-
%    coord(X1), coord(Y1), coord(X2), coord(Y2).

% each position can have at most one tile in it
% -> thus tiles cannot overlap
%0 { onboard(N,X1,Y1,X2,Y2) : coord(X1), coord(Y1), coord(X2), coord(Y2) } 1 :-
%    tilename(N).

% sbagliato
%:- onboard(N,X11,Y11, X12, Y12), onboard(N,X21,Y21,X22,Y22),
%    X11 != X21, Y11 != Y21, X12 != X22, Y12 != Y22.

%* -----------------------------------------------------------------------------
% These constraints are unuseful!!!
% can't put tiles outside board
:- onboard(N,X1,Y1,X2,Y2), tilename(N),
    coord(X1), coord(Y1), coord(X2), coord(Y2),
    X1 < 1.

:- onboard(N,X1,Y1,X2,Y2), tilename(N),
    coord(X1), coord(Y1), coord(X2), coord(Y2),
    X2 > h.

:- onboard(N,X1,Y1,X2,Y2), tilename(N),
    coord(X1), coord(Y1), coord(X2), coord(Y2),
    Y1 < 1.

:- onboard(N,X1,Y1,X2,Y2), tilename(N),
    coord(X1), coord(Y1), coord(X2), coord(Y2),
    Y2 > h.
----------------------------------------------------------------------------- *%

%* -----------------------------------------------------------------------------
% a tile can be next only to one another tile
% (considering the meaning of "next" given by my model)
%1 { next(N1,N2) : tilename(N1) } 1 :- tilename(N2).
%1 { next(N1,N2) : tilename(N2) } 1 :- tilename(N1).
:- next(N1,N2), next(N1,N3), 
    tilename(N1), tilename(N2), tilename(N3),
    N2 != N3.

:- next(N1,N2), next(N3,N2),
    tilename(N1), tilename(N2), tilename(N3),
    N1 != N2.


%% Symmetry breaking ??

%% Sequence definition
sequence(S+1) :- S = #count{ N1 : next(N1,_) }.
#show sequence/1.
#show onboard/5.
#maximize { S : sequence(S) }.
----------------------------------------------------------------------------- *%

%% INPUT TEST
tile(1,1,1).
tile(2,1,2).
tile(3,2,2).
%tile(4,2,1).
%tile(5,2,2).
%tile(6,1,1).
%tile(7,1,1).
%tile(8,2,1).
%tile(9,1,2).
%tile(10,2,2).
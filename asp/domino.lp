%% Exercise 9 - (Custom) Domino
%% Gabriele Venturato (125512)
%% Automated Reasoning 2017/2018
%% tested with clingo 5.3.0

value(1..k).
tilename(1..n).
coord(1..h).

% Input: k, n, h, tile(n,l,r)

% ---------------------------------------------------------------------------- %
%% Placed
% a tile can be "placed on" the board at position (x,y)
% a tile is placed, if it is placed on a position
placed(T) :- placed_on(T,_,_).

% Left and Right values
% the value in (x,y) is the left (or top) one of the tile T
leftval(T,X,Y) :- placed_on(T,X,Y), placed_on(T,X+1,Y), coord(X+1).
leftval(T,X,Y) :- placed_on(T,X,Y), placed_on(T,X,Y+1), coord(Y+1).

% the value in (x,y) is the right (or bottom) one of the tile T
rightval(T,X,Y) :- placed_on(T,X,Y), not leftval(T,X,Y).

%% Compatible
% two tiles are compatible if and only if they are not the same tile
% and have the same value in position left and right
compatible(T1,T2) :- tile(T1,_,R), tile(T2,L,_), T1 != T2, R == L.
:- compatible(T,T).
:- compatible(T1,T2), tile(T1,_,R), tile(T2,L,_), R != L.


% ----------------------------- CONSTRAINTS ---------------------------------- %
%% Placed
% and can occupy exactly zero or exactly two positions
0 { placed_on(T,X,Y) : coord(X), coord(Y) } 2 :- tilename(T).
{ placed_on(T,X,Y) : coord(X), coord(Y) } != 1 :- tilename(T).

%% a tile can be only placed in two consecutive (no diagonal) cells of the board
:- placed_on(T,X1,Y1), placed_on(T,X2,Y2), X1 != X2, Y1 != Y2.
:- placed_on(T,X,Y1), placed_on(T,X,Y2), Y1 < Y2, Y2 != Y1 + 1.
:- placed_on(T,X1,Y), placed_on(T,X2,Y), X1 < X2, X2 != X1 + 1.

%% tiles can't overlap
0 { placed_on(T,X,Y) : tilename(T) } 1 :- coord(X), coord(Y).

%% Next
% define when a tile can be next to another
0 { next(T1,T2) : tilename(T2) } 1 :- tilename(T1), compatible(T1,T2).
0 { next(T1,T2) : tilename(T1) } 1 :- tilename(T2), compatible(T1,T2).
:- next(T1,T2), not compatible(T1,T2).
:- next(T,T).

% a tile can be next only to one another tile
:- next(T,T1), next(T,T2), T1 != T2.
:- next(T1,T), next(T2,T), T1 != T2.

%% Next and Placed
% a tile can't be placed and not next to anything
:- placed(T), placed(T1), T != T1, not next(T,_), not next(_,T).

% a tile can't be next to another if it is not placed
:- next(T,_), not placed(T).
:- next(_,T), not placed(T).

%% Where to place (if two tiles are next)
% if two tiles are on the same column the row distance must be 1
:- placed_on(T1,X1,Y1), placed_on(T2,X2,Y2),
    T1 != T2, next(T1,T2),
    rightval(T1,X1,Y1), leftval(T2,X2,Y2),
    X1 == X2,
    |Y1 - Y2| != 1.

% if two tiles are on the same row the column distance must be 1
:- placed_on(T1,X1,Y1), placed_on(T2,X2,Y2),
    T1 != T2, next(T1,T2),
    rightval(T1,X1,Y1), leftval(T2,X2,Y2),
    Y1 == Y2,
    |X1 - X2| != 1.

% they can't be on a different row and different column
:- placed_on(T1,X1,Y1), placed_on(T2,X2,Y2),
    T1 != T2, next(T1,T2),
    rightval(T1,X1,Y1), leftval(T2,X2,Y2),
    |Y1 - Y2| != 0,
    |X1 - X2| != 0.

% both different from 1 is not necessary because overlap is not allowed

%% Symmetry breaking
% if a sequence is long l, then there exist a sequence of length l which starts
% from top left corners
placed_on(T,1,1) :- firsttile(T).
placed_on(T,2,1) :- firsttile(T).

% firsttile is T if there are at least two tiles and T is the first
% or if T is the only tile placed.
firsttile(T) :- next(T,_), not next(_,T), placed(T1), T1 != T.
firsttile(T) :- not next(_,_), placed(T).

%% Sequence definition
sequence(S+1) :- S = #count{ T: next(T,_) }.

#maximize { S : sequence(S) }.

% CLEAN HERE
% Activate these output if you want to "humanize" the result
%#show sequence/1.
%#show placed_on/3.
%#show next/2.
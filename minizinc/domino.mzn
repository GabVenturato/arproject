% Exercise 9 - (Custom) Domino
% Gabriele Venturato (125512)
% Automated Reasoning 2017/2018

include "alldifferent.mzn";
% -------------------------------- DATA -------------------------------------- %
% Input parameters
int: h; % board dimension
int: n; % number of tiles
int: k; % max value on tiles

% tiles[t,1] is the left value of tile t (2 is the right one)
array[1..n, 1..2] of 1..k: tiles;

% board[x,y] = t means that the tile t is in position (x,y)
array[1..h, 1..h] of var 0..n: board;

var 1..n: s; % length of the sequence
array[1..n] of var 0..n: sequence;


% ---------------------------- CONSTRAINTS ----------------------------------- %
% SEQUENCE
% two tiles to be in sequence must respect values in them
constraint forall (i in 1..s-1) (
  tiles[ sequence[i] , 2 ] = tiles[ sequence[i+1] , 1 ]
);

% after last tile, can't have other tiles in the sequence
constraint forall (i in s+1..n) (
  sequence[i] = 0
);

% at least one tile in the sequence (avoid empty sequence)
constraint sequence[1] > 0;

% can use each tile at most once in the sequence
constraint forall(t in 1..n) (
  sum( [ bool2int( sequence[i] == t ) | i in 1..n ] ) <= 1
);

% BOARD
% a tile placed on the board must occupy at least two consequent cells
constraint forall( i,j in 1..h, t in 1..n ) (
  board[i,j] = t -> exists( a,b in {-1,0,1} where
      i+a >= 1 /\ j+b >= 1 /\
      i+a <= h /\ j+b <= h /\
      abs(a) + abs(b) = 1
    ) ( board[i+a,j+b] = t )
);

% for each row a tile can occupy at most two consequent cells
constraint forall( t in 1..n ) (
  sum( [ bool2int(board[i,j] == t) | i,j in 1..h ] ) <= 2
);

constraint forall( i in 1..s-1 ) (
  exists( t1x,t1y,t2x,t2y in 1..h ) (
    board[t1x,t1y] = sequence[i] /\ rightval(board[t1x,t1y],t1x,t1y) /\
    board[t2x,t2y] = sequence[i+1] /\ leftval(board[t2x,t2y],t2x,t2y) /\
  abs(t1y - t2y) <= 1 /\ 
  abs(t1x - t2x) <= 1 /\ 
  abs(t1y - t2y) + abs(t1x - t2x) = 1)
);

% a tile can be on board iff it is in the sequence
constraint forall( t in 1..n ) (
  exists(x,y in 1..h) (board[x,y] = t) <-> exists(i in 1..s) (sequence[i] = t)
);

% SYMMERTRY BREAKING
% first tile of the sequence can be on top left corner or top right
constraint sequence[1] = board[1,1] \/ sequence[1] = board[1,h];


% ------------------------------- OUTPUT ------------------------------------- %
solve maximize s; % <--- try different heuristics

output [ show(s) ++ "\n" ++ show(sequence) ] ++
["\n"] ++ 
[ 
  show(board[i,j]) ++
  if (j > 9) then "  " else " " endif ++
  if (j mod h == 0) then "\n" else "" endif
  | i,j in 1..h
];


% ----------------------------- PREDICATES ----------------------------------- %
% true if position (x,y) is the right (resp. bottom) value of tile t
predicate rightval(var int: t, 1..h: x, 1..h: y) =
  exists(i,j in 1..h) (
    board[i,j] == t /\ board[x,y] == t /\ ( x > i \/ y > j )
  );
  
% true if position (x,y) is the left (resp. top) value of tile t
predicate leftval(var int: t, 1..h: x, 1..h: y) =
  exists(i,j in 1..h) (
    board[i,j] == t /\ board[x,y] == t /\ ( x < i \/ y < j )
  );
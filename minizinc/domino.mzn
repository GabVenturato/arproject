% Exercise 9 - (Custom) Domino
% Gabriele Venturato (125512)
% Automated Reasoning 2017/2018
% tested with mzn-gecode v2.0.2 (i.e. fzn-gecode 5.1.0)

% -------------------------------- DATA -------------------------------------- %
% Input parameters
int: h; % board dimension
int: n; % number of tiles
int: k; % max value on tiles

% tiles[t,1] is the left value of tile t (2 is the right one)
array[1..n, 1..2] of 1..k: tiles;

% board[x,y] = p means that the tile t is in position p on the sequence,
% and that it is placed on position (x,y) on board
% (you can forget about this detail and think that a tile is placed on board,
% and not it's corresponding position in the sequence)
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
constraint forall( i,j in 1..h, p in 1..s ) (
  board[i,j] = p -> exists( a,b in {-1,0,1} where
      i+a >= 1 /\ j+b >= 1 /\
      i+a <= h /\ j+b <= h /\
      abs(a) + abs(b) = 1
    ) ( board[i+a,j+b] = p )
);

% for each row a tile can occupy at most two consequent cells
constraint forall( p in 1..s ) (
  sum( [ bool2int(board[i,j] == p) | i,j in 1..h ] ) <= 2
);

% defining where a tile can be placed on board
constraint forall( i in 1..s-1 ) (
  exists( t1x,t1y,t2x,t2y in 1..h ) (
    board[t1x,t1y] = i /\ rightval(board[t1x,t1y],t1x,t1y) /\
    board[t2x,t2y] = i+1 /\ leftval(board[t2x,t2y],t2x,t2y) /\
  abs(t1y - t2y) <= 1 /\ 
  abs(t1x - t2x) <= 1 /\ 
  abs(t1y - t2y) + abs(t1x - t2x) = 1)
);

% a tile can be on board iff it is in the sequence
constraint forall( p in 1..s ) (
  exists(x,y in 1..h) (board[x,y] = p)
);

% SYMMERTRY BREAKING
% the longest sequence will start from top left corner with the tile
% placed horizontally
constraint board[1,1] = 1 /\ board[1,2] = 1;

% try only sequences with length compatible with the board dimension
constraint s <= (h*h div 2);

% sequence must be > h (imposed by assignment)
% this could lead to unsatifiable situation if there are not enough tiles
% compatilble to build a sequence length at least h
constraint s > h;

% don't consider permutation of tiles with the same values
/* this can be activated with high "n" and low "k", otherwise it is not worth it
constraint forall( i in 1..s-1, j in i+1..s ) (
  ( tiles[ sequence[i], 1 ] ==  tiles[ sequence[j], 1 ] /\
  tiles[ sequence[i], 2 ] ==  tiles[ sequence[j], 2 ] )
  -> sequence[i] < sequence[j]
);
*/

constraint forall( i,j in 1..h ) ( board[i,j] <= s );

% ------------------------------- OUTPUT ------------------------------------- %
solve :: seq_search([
    int_search([s], input_order, indomain_min, complete),
    int_search(sequence, first_fail, indomain_min, complete),
    int_search([ board[i,j] | i,j in 1..h], first_fail, indomain_min, complete)])
  maximize s;

output [ 
  "Sequence length: " ++ show(s) ++ 
  "\nSequence: " ++ show(sequence) ]
++ ["\nBoard:\n"] ++ 
[ 
  show(board[i,j]) ++ "\t" ++
  if (j mod h == 0) then "\n" else "" endif
  | i,j in 1..h
];


% ----------------------------- PREDICATES ----------------------------------- %
% true if position (x,y) is the right (resp. bottom) value of tile t
predicate rightval(var int: p, 1..h: x, 1..h: y) =
  exists(i,j in 1..h) (
    board[i,j] == p /\ board[x,y] == p /\ ( x > i \/ y > j )
  );
  
% true if position (x,y) is the left (resp. top) value of tile t
predicate leftval(var int: p, 1..h: x, 1..h: y) =
  exists(i,j in 1..h) (
    board[i,j] == p /\ board[x,y] == p /\ ( x < i \/ y < j )
  );
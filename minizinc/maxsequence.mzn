% Exercise 9 - Max Domino Sequence
% Gabriele Venturato (125512)
% Automated Reasoning 2017/2018

% -------------------------------- DATA -------------------------------------- %
% Input parameters
int: h; % useless but leave it here to use same test file as domino.mzn
int: n; % number of tiles
int: k; % max value on tiles

% tiles[t,1] is the left value of tile t (2 is the right one)
array[1..n, 1..2] of 1..k: tiles;

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

% don't consider permutation of tiles with the same values
constraint forall( i in 1..s-1, j in i+1..s ) (
  ( tiles[ sequence[i], 1 ] ==  tiles[ sequence[j], 1 ] /\
  tiles[ sequence[i], 2 ] ==  tiles[ sequence[j], 2 ] )
  -> sequence[i] < sequence[j]
);

% ------------------------------- OUTPUT ------------------------------------- %
solve :: seq_search([
    int_search([s], input_order, indomain_min, complete),
    int_search(sequence, first_fail, indomain_min, complete)])
  maximize s;
%solve maximize s;

output [ 
  "Sequence length: " ++ show(s) ++ 
  "\nSequence: " ++ show(sequence) ];
# Gabriele Venturato (125512)
# Automated Reasoning 2017/2018
# Script to generate random instances.
# instances will be created into: ./instances/

import os
from random import randint

# PARAMETERS
TOTAL_INSTANCES = 100

N = [20,30,40,50,60]
K = [ int(x/5) for x in N ]
H = [7,8,9,10,11]

# define and create (if not exists) the target folder
target_folder = "instances/"
os.makedirs(os.path.dirname(target_folder), exist_ok=True)

# instances for every parameter combination
istances_per_config = int( TOTAL_INSTANCES / (len(N) * len(H)) )

for (n,k) in zip(N,K):
    for h in H:
        for i in range(1,istances_per_config+1):
            ## generate n random tiles with values in [1..k]
            T = []
            for _ in range(0,n):
                lval = randint(1,k)
                rval = randint(1,k)
                T.append( {'l':lval, 'r':rval} )

            ## filename generation
            f = "in_" + str(n) + "_" + str(k) + "_" + str(h) + "_" + str(i)
            asp_filename =  target_folder + f + ".lp"
            mz_filename = target_folder + f + ".dzn"

            ## open file, write everything, and close
            # asp
            fp_asp = open(asp_filename, "w")
            fp_asp.write("#const n = " + str(n) + ".\n")
            fp_asp.write("#const k = " + str(k) + ".\n")
            fp_asp.write("#const h = " + str(h) + ".\n")
            for j,t in enumerate(T,1):
                fp_asp.write("tile(" + 
                    str(j) + "," 
                    + str(t['l']) + "," 
                    + str(t['r']) + ").\n"
                    )
            fp_asp.close()

            # minizinc
            fp_mz = open(mz_filename, "w")
            # --- need to do ---
            fp_mz.close()







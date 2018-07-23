import os
import re
from operator import itemgetter

output_dir = "output/"
directory = os.fsencode(output_dir)

times = []

for file in os.listdir(directory):
    filename = os.fsdecode(file)
    if filename.endswith(".txt"):
        f = os.path.join(output_dir, filename)

        # extract parameters from filename
        v = f.split('_')
        n = v[1]
        k = v[2]
        h = v[3]
        [i,_] = v[4].split(".")

        # extract solving info from content
        optimum_flag = "0"
        optimum = 0
        time = 0

        fp = open(f,'r')

        for line in fp:
            if "==========" in line:
                optimum_flag = "1"

            if "Sequence length" in line:
                # retreive optimum val
                m = re.search('Sequence length: (.+)', line)
                if m:
                    optimum = m.group(1)
                        
            if "solvetime:" in line:
                # retreive solving time
                m = re.search('solvetime:.+\(([0-9]*\.[0-9]*) ms\)', line)
                if m:
                    time = "{0:.2f}".format( float(m.group(1))/1000 )

        fp.close()
        times.append([n,k,int(h),int(i),str(time),optimum_flag,str(optimum)])

times = sorted(times, key=itemgetter(0,1,2,3))

for i,el in enumerate(times):
    el = map(lambda x:str(x),el)
    print( "\t".join(el) )
        
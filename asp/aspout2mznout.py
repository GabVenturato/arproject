#!/usr/bin/python
# Gabriele Venturato (125512)
# Automated Reasoning 2017/2018
# Script to convert clingo output format to be the same as minizinc.

# NOT FINISHED!!!!!
# I SHOULD RENAME IT SOMETHING LIKE: humanize_clingo
# one problem is that I need the board dimension to "humanize" the result

import sys, getopt
import re

def main(argv):
    asp_out_filename = ''
    mznlike_out_filename = 'cleaned_output.txt'

    try:
        opts, args = getopt.getopt(argv,"hi:o:",["help","ifile=","ofile="])
    except getopt.GetoptError:
        print('Usage: aspout2mznout.py -i <inputfile> -o <outputfile>')
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print('Usage: aspout2mznout.py -i <inputfile> -o <outputfile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            asp_out_filename = arg
        elif opt in ("-o", "--ofile"):
            mznlike_out_filename = arg

    if asp_out_filename == '':
        print('You must specifiy an input file.\n')
        print('Usage: aspout2mznout.py -i <inputfile> -o <outputfile>')
        sys.exit(2)

    # open input file and process
    asp_fp = open( asp_out_filename, 'r' )
    asp = [ l.replace('\n', '') for l in asp_fp.readlines() ]

    asp = [ l for l in asp if "sequence" in l ]

    for l in asp:
        print(l)

    #out = []
    #for l in asp:
    #    m = re.search('sequence\(.\)', l)
    #    if m:
    #        found = m.group(1)

    asp_fp.close()

    # write everything in output file
    #mzn_fp = open( mznlike_out_filename, 'w' )
    #mzn_fp.close()

if __name__ == "__main__":
   main(sys.argv[1:])
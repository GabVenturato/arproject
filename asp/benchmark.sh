#!/bin/bash
# Gabriele Venturato (125512)
# Automated Reasoning 2017/2018
# Script to run the asp domino model on all instances in "input/" folder.

# launch "./benchmark.sh" to test on all the instances
# launch "./benchmark.sh -s" (or --sample) to test on 10% of all instances

SAMPLE=false
TOT=100
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--sample)
    SAMPLE=true
    shift # past argument
    ;;
    *)    # unknown option
    shift # past argument
    ;;
esac
done

if [ "$SAMPLE" = true ]; then
    TOT=10
fi

# first sampling position
samplingposition=$((RANDOM % 10)) # from 0 to 9

## clean output directory
# if sampling erase and do a new sampling
# if not sampling and output files already exists: warning and stop
if [ "$SAMPLE" = false ]; then
    if [ "$(ls -A output | grep txt)" ]; then
        echo "WATCH OUT! You have already generate some outputs."
        echo "Check what's going on. If you are not interested anymore: clean!"
        exit 1
    fi
else
    rm -f output/sample/*.txt
fi

## loop through all instances
index=0
i=1
for filename in input/*; do
    # prepare output filename
    f=$(basename $filename)
    f=${f%.*}
    outfile="output/out_"${f##in_}".txt"
    if [ "$SAMPLE" = true ]; then
        outfile="output/sample/out_"${f##in_}".txt"
    fi
    # execute if sampling is not sette up
    # OR if it is setted up and this is a samplingposition
    if [[ "$SAMPLE" = false ]] || 
        [[ "$SAMPLE" = true  &&  $index = $samplingposition ]]; then
        echo "$i/$TOT --- TESTING FILE: $filename ---"
        clingo $filename domino.lp --time-limit=300 > $outfile
        ((i++))
    fi
    ((index++))
    # if index reaches next decade recalulate the sampling position
    if (( ( index % 10 == 0 ) && ( index < 100 ))); then
        samplingposition=$(( index + (RANDOM % 10) ))
    fi
done
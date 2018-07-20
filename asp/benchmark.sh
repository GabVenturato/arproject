#!/bin/bash
# Gabriele Venturato (125512)
# Automated Reasoning 2017/2018
# Script to run the asp domino model on all instances in "input/" folder.

POSITIONAL=()
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
rm -f output/*.txt

## loop through all instances
index=0
i=1
for filename in input/*; do
    # prepare output filename
    f=$(basename $filename)
    f=${f%.*}
    outfile="output/out_"${f##in_}".txt"
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
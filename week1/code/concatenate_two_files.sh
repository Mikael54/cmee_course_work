#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Please provide two input files and one output file"
    exit 1
fi

# Check if first input file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' does not exist"
    exit 1
fi

# Check if second input file exists
if [ ! -f "$2" ]; then
    echo "Error: File '$2' does not exist"
    exit 1
fi


cat $1 > "../results/$(basename "$3")"
cat $2 >> "../results/$(basename "$3")"
echo "Files $1 and $2 have been concatenated into $3 in the results directory"
cat ../results/$3
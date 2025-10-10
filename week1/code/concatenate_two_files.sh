#!/bin/bash
# Author: Mikael Minten mikael.minten25@imprial.ac.uk
# Desc: script to concatenate two files into one
# Argument: 1 -> First input file, 2 -> Second input file, 3 -> Output file name (will be saved in results directory)
# Saves the output into the results directory
# Date: Oct 2025

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
echo "Files $(basename "$1") and $(basename "$2") have been concatenated into $(basename "$3") in the results directory"
cat ../results/$3
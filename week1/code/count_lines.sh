#!/bin/bash
# Author: Mikael Minten mikael.minten25@imprial.ac.uk
# Script: count_lines.sh
# Desc: script to count the number of lines in a file
# Argument: 1 -> Input file
# Date: Oct 2025

# Checks for an input file
if [ $# -eq 0 ]; then
    echo "Please provide a file"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' does not exist"
    exit 1
fi

# Counts lines
NumLine=`wc -l < $1`
echo "the file $1 has $NumLine lines"
echo



#!/bin/bash
# Author: Mikael Minten mikael.minten25@imprial.ac.uk
# Desc: script to count the number of lines in a file
# Argument: 1 -> Input file
# Date: Oct 2025

if [ $# -eq 0 ]; then
    echo "Please provide a file"
    exit 1
fi


NumLine=`wc -l < $1`
echo "the file $1 has $NumLine lines"
echo
#!/bin/sh
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: csvtospace
# Description: substitute the comma in the files with spaces
# Saves the output into a .txt file
# Arguments: 1 -> csv file
# Date: Oct 2019

if [ $# -eq 0 ]; then
    echo "Please provide a file"
    exit 1
fi

if ! grep -q $',' $1; then
    echo "This file has no commas"
    exit 1
fi 

echo "Creating a space separated version of $1 ..."
cat "$1" | tr -s "," " " >> "../results/$(basename "$1" .csv).txt"
echo "Done!"
exit

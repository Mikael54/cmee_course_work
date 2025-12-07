#!/bin/sh
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: csv_to_space.sh
# Description: substitute the comma in the files with spaces and saves the output into a .txt file
# Arguments: 1 -> csv file
# Date: Oct 2025

# Checks if there is an input file
if [ $# -eq 0 ]; then
    echo "Please provide a file"
    exit 1
fi

# check if the file exist
if [ ! -f "$1" ]; then
    echo "Error: File '$1' does not exist"
    exit 1
fi

# Check if there are commas in the file
if ! grep -q $',' $1; then
    echo "This file has no commas"
    exit 1
fi 

echo "Creating a space separated version of $1 ..."
# Changing all commas to spaces and exports it to results
cat "$1" | tr -s "," " " >> "../results/$(basename "$1" .csv).txt"
echo "Done!"
exit

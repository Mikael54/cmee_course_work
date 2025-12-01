#!/bin/sh
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: tabtocsv.sh
# Description: substitute the tab in the files with commas and saves the output into a .csv file
# Arguments: 1 -> tab file
# Date: Oct 2019

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

# Check if there are tabs in the file
if ! grep -q $'\t' $1; then
    echo "This file has no tabs"
    exit 1
fi 


echo "Creating a tab separated version of $1 ..."
# replaces tab with commas and puts it in the results folder 
cat $1 | tr -s "\t" "," >> "../results/$(basename "$1" .txt).csv"
echo "Done!"
exit

#!/bin/sh
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: tabtocsv
# Description: substitute the tab in the files with commas
#
# Saves the output into a .csv file
# Arguments: 1 -> tab file
# Date: Oct 2019

if [ $# -eq 0 ]; then
    echo "Please provide a file"
    exit 1
fi

if ! grep -q $'\t' $1; then
    echo "This file has no tabs"
    exit 1
fi # note- does a file with just one value contain tabs?- maybe this test is bad- do double check!!


echo "Creating a tab separated version of $1 ..."
cat $1 | tr -s "\t" "," >> "../results/$(basename "$1").csv"
echo "Done!"
exit

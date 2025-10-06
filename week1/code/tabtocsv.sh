#!/bin/sh
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: tabtocsv.sh
# Description: substitute the tabs in the files with commas
#
# Saves the output into a .csv file
# Arguments: 1 -> tab delimited file
# Date: Oct 2019

if [$# -eq 0]; then
    echo "Please provide a file"
    exit 1
fi

if grep -q $'\t' $1; then
    echo "This file has no tabs"
    exit 1
fi # note- does a file with just one value contain tabs?- maybe this test is bad- do double check!!


echo "Creating a comma delimited version of $1 ..."
cat $1 | tr -s "\t" "," >> $1.csv
echo "Done!"
exit


# Plan:
# 1. edit the script so that if there is no input (or if the input in no correct?)
# it will print a useful message and exit
# tab should always have a .txt file- right?- so i can check for this lol...

# I can use an if then statement
# step 1. check if the number of arguments is at leats one
# if not - print a message and exit
# step 2. check if the first argument ends with .txt - update- might be better if I just check if there are tabs
#!/bin/sh
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: csvtospace
# Description: substitute the comma in the files with spaces
#
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
fi # note- does a file with just one value contain commas?- maybe this test is bad- do double check!!


echo "Creating a space separated version of $1 ..."
cat $1 | tr -s "," " " >> $1.txt
echo "Done!"
exit

# another idea- maybe write the script so it removes the .csv before changing it to txt?
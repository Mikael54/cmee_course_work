# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: basic_io1.py
# Description: Reads file and reads a file while skipping blank lines
# Arguments: None
# Date: Oct 2025

import os
import sys

# Check if the input file exists
input_file = '../data/test.txt'
if not os.path.exists(input_file):
    print(f"Error: File '{input_file}' not found.")
    print("Please make sure the file exists in the data directory.")
    sys.exit(1)

# Open a file for reading
f = open(input_file, 'r')
# use implicit for loop 
# if the object is a file, python will cycle over lines
for line in f:
    print(line)

# close the file
f.close()

# same example (skip blank lines)
f = open(input_file, 'r')
for line in f:
    if len(line.strip()) > 0:
        print(line)

f.close()
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: basic_io1.py
# Description: Reads file and reads a file while skipping blank lines
# Arguments: None
# Date: Oct 2019


# Open a file for reading
f = open('../data/test.txt', 'r')
# use implicit for loop 
# if the object is a file, python will cycle over lines
for line in f:
    print(line)

# close the file
f.close()

# same example (skip blank lines)
f = open('../data/test.txt', 'r')
for line in f:
    if len(line.strip()) > 0:
        print(line)

f.close
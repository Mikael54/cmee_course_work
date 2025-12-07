# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: basic_io2.py
# Description: Writes a text file with numbers 1-100
# Arguments: None
# Date: Oct 2025

# Save the elements of a list to a file
list_to_save = range(100)

f = open('../results/testout.txt','w')
for i in list_to_save:
    f.write(str(i) + '\n') ## Add a new line at the end

f.close()
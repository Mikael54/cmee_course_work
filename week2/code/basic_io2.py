# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: basic_io2.py
# Description: Writes a text file with numbers 1-100
# Arguments: None
# Date: Oct 2025

import os
import sys

# Save the elements of a list to a file
list_to_save = range(100)

# Check if results directory exists
output_file = '../results/testout.txt'
results_dir = os.path.dirname(output_file)
if not os.path.exists(results_dir):
    print(f"Error: Directory '{results_dir}' not found.")
    print("Please create the results directory first.")
    sys.exit(1)

f = open(output_file, 'w')
for i in list_to_save:
    f.write(str(i) + '\n') ## Add a new line at the end

f.close()
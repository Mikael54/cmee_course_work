# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: basic_io3.py
# Description: Writes a .p and then reads it
# Arguments: None
# Date: Oct 2025

import os
import sys
import pickle

# To save an object (even complex) for later use
my_dictionary = {"a key": 10, "another key": 11}

# Check if data directory exists
pickle_file = '../data/testp.p'
data_dir = os.path.dirname(pickle_file)
if not os.path.exists(data_dir):
    print(f"Error: Directory '{data_dir}' not found.")
    print("Please create the data directory first.")
    sys.exit(1)

f = open(pickle_file, 'wb') ## note the b: accept binary files
pickle.dump(my_dictionary, f)
f.close()

## Load the data again
# Check if pickle file exists before trying to load it
if not os.path.exists(pickle_file):
    print(f"Error: File '{pickle_file}' not found.")
    print("Cannot load the pickle file.")
    sys.exit(1)

f = open(pickle_file, 'rb')
another_dictionary = pickle.load(f)
f.close()

# print the dictionary
print(another_dictionary)
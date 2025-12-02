# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: basic_io3.py
# Description: Writes a .p and then reads it
# Arguments: None
# Date: Oct 2019


# To save an object (even complex) for later use
my_dictionary = {"a key": 10, "another key": 11}

import pickle

f = open('../data/testp.p','wb') ## note the b: accept binary files
pickle.dump(my_dictionary, f)
f.close()

## Load the data again
f = open('../data/testp.p','rb')
another_dictionary = pickle.load(f)
f.close()

# print the dictionary
print(another_dictionary)
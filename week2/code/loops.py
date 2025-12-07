#!/usr/bin/env python3
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: loops.py
# Description: Shows loop functionality.
# Arguments: None
# Date: Oct 2025


# prints 0-4
for i in range(5):
    print(i)

# Create a list with different data types
my_list = [0, 2, "geronimo!", 3.0, True, False]
for k in my_list:
    print(k)

# For loop with accumulator
total = 0
summands = [0, 1, 11, 111, 1111]
for s in summands:
    total = total + s
    print(total)


# WHILE loop, counts to 100
z = 0
while z < 100:
    z = z + 1
    print(z)
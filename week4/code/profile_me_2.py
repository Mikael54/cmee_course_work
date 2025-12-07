#!/usr/bin/env python3

# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: profile_me_2.py
# Description: A script to be profiled- can be compared to profile_me.py.
# Arguments: None
# Date: Oct 2025

# A function that returns a list of squares
def my_squares(iters):
    out = [i ** 2 for i in range(iters)]
    return out

# A function that joins a string multiple times
def my_join(iters, string):
    out = ''
    for i in range(iters):
        out += ", " + string
    return out

# A function that runs the other two functions
def run_my_funcs(x,y):
    print(x,y)
    my_squares(x)
    my_join(x,y)
    return 0

# Run the functions to be profiled
run_my_funcs(10000000,"My string")
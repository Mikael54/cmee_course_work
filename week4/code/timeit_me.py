#!/usr/bin/env python3

# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: timeit_me.py
# Description: A script to compare the performance of pro.
# Arguments: None
# Date: Oct 2025


##############################################################################
# loops vs. list comprehensions: which is faster?
##############################################################################

iters = 1000000

import timeit

from profile_me import my_squares as my_squares_loops

from profile_me_2 import my_squares as my_squares_lc

##############################################################################
# loops vs. the join method for strings: which is faster?
##############################################################################

mystring = "my string"

from profile_me import my_join as my_join_join

from profile_me_2 import my_join as my_join

#!/usr/bin/env python3
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: sysargv.py
# Description: shows how the import sys works and how it relates to argument name.
# Arguments: None, but can be included if you want
# Date: Oct 2025

import sys
print("This is the name of the script: ", sys.argv[0])
print("Number of arguments: ", len(sys.argv))
print("The arguments are: " , str(sys.argv))
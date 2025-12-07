#!/usr/bin/env python3
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: using_name.py
# Description: shows how the __name__ works in python pograms.
# Arguments: None
# Date: Oct 2025

if __name__ == '__main__':
    print('This program is being run by itself!')
else:
    print('I am being imported from another script/program/module!')

print("This module's name is: " + __name__)
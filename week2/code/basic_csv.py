# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: basic_csv.py
# Description: A simple script to read and write a csv file
# Arguments: None
# Date: Oct 2025


import csv
import os
import sys

# Check if the input file exists
input_file = '../data/test_csv.csv'
if not os.path.exists(input_file):
    print(f"Error: File '{input_file}' not found.")
    print("Please make sure the file exists in the data directory.")
    sys.exit(1)

# Read a file containing:
# 'Species','Infraorder','Family','Distribution','Body mass male (Kg)'
with open(input_file, 'r') as input:

    csvread = csv.reader(input)
    temp = []
    for row in csvread:
        temp.append(tuple(row))
        print(row)
        print("The species is", row[0])

# Write a csv with only species and body mass
# create or overwrite '../results/body_mass.csv'.
with open(input_file, 'r') as input:
    with open('../results/body_mass.csv', 'w') as output:

        csvread = csv.reader(input)
        csvwrite = csv.writer(output)
        for row in csvread:
            print(row)
            # write species and the (string) body mass value
            csvwrite.writerow([row[0], row[4]])
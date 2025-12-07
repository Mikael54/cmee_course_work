# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: basic_csv.py
# Description: A simple script to read and write a csv file
# Arguments: None
# Date: Oct 2025


import csv

# Read a file containing:
# 'Species','Infraorder','Family','Distribution','Body mass male (Kg)'
with open('../data/test_csv.csv', 'r') as f:

    csvread = csv.reader(f)
    temp = []
    for row in csvread:
        temp.append(tuple(row))
        print(row)
        print("The species is", row[0])

# Write a csv with only species and body mass
# create or overwrite '../results/body_mass.csv'.
with open('../data/test_csv.csv', 'r') as f:
    with open('../results/body_mass.csv', 'w') as g:

        csvread = csv.reader(f)
        csvwrite = csv.writer(g)
        for row in csvread:
            print(row)
            # write species and the (string) body mass value
            csvwrite.writerow([row[0], row[4]])
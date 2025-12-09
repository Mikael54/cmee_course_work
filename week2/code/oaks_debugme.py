#!/usr/bin/env python3

"""

A code that identifies oaks by name and can account for typos.

"""

__appname__ = '[Oaks Debugme]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'

import csv
import sys

import doctest # Import the doctest module
import difflib

#Define function
def is_an_oak(name):
    """
    >>> is_an_oak('Fraxinus, excelsior')
    False

    >>> is_an_oak('quercus, robur') 
    True

    >>> is_an_oak('Quercus, robur') 
    True

    >>> is_an_oak('Quercuss, robur') 
    True
    
    """
    # extract genus name (first word) and make it lowercase
    genus = name.strip().split()[0].lower()

    # Using fuzzy matching to account for typos
    similarity = difflib.SequenceMatcher(None, genus, 'quercus').ratio()
    return similarity > 0.8


def main(argv): 
    with open('../data/test_oak_data.csv', 'r') as testing_data, \
         open('../results/just_oaks_data.csv', 'w', newline='') as just_oaks:
        
        taxa = csv.reader(testing_data)

        # Read header properly
        header = next(taxa)

        csvwrite = csv.writer(just_oaks)
        csvwrite.writerow(header)
        taxa = csv.reader(testing_data) 
                
        for row in taxa:
            if not row:  
                continue
                
            genus = row[0].strip()
            print(f"The genus is: {genus}")
            
            if is_an_oak(genus):
                print(f"FOUND AN OAK!\n")
                csvwrite.writerow(row)
            
    return 0
    
if __name__ == "__main__":
    doctest.testmod()
    status = main(sys.argv)
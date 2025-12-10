#!/usr/bin/env python3

"""
A code that finds the best allignent for two strands based on a csv file
"""

__appname__ = '[Align Sequences]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import csv
import os


def import_values():
    """
    Imports sequence data from a CSV file and orders them by length.
    
    Reads two DNA sequences from ../data/align_seq_sample.csv and ensures 
    the longer sequence is assigned as s1.
    
    Returns:
        tuple: (s1, s2, l1, l2) where:
            - s1 : The longer sequence
            - s2 : The shorter sequence 
            - l1 : Length of s1
            - l2 : Length of s2
    """
    # Check if the file exists
    filepath = "../data/align_seq_sample.csv"
    if not os.path.exists(filepath):
        print(f"Error: File '{filepath}' not found.")
        print("Please make sure the file exists in the data directory.")
        sys.exit(1)
    
    # Check if the file is readable
    if not os.access(filepath, os.R_OK):
        print(f"Error: File '{filepath}' is not readable.")
        sys.exit(1)
    
    with open(filepath, "r") as file:
        reader = csv.reader(file)
        rows = list(reader)
        seq1 = ''.join(rows[0]) # using join to make it a string
        seq2 = ''.join(rows[1])

    l1 = len(seq1)
    l2 = len(seq2)
    if l1 >= l2:
        s1 = seq1
        s2 = seq2
    else:
        s1 = seq2
        s2 = seq1
        l1, l2 = l2, l1 # swap the two lengths

    return(s1, s2, l1, l2)


# A function that computes a score by returning the number of matches 
def calculate_score(s1, s2, l1, l2, startpoint):
    """
    Calculate the alignment score at a given starting position.
    
    Compares the shorter sequence (s2) against the longer sequence (s1) 
    starting at the specified position and counts matching bases.
    
    Args:
        s1 : The longer sequence
        s2 : The shorter sequence
        l1 : Length of s1
        l2 : Length of s2
        startpoint : Position in s1 where s2 alignment begins

    Returns:
        int: Number of matching bases (e.g., 5 matches out of 10 bases)
    """
    matched = "" # to hold string displaying alignements
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*"
                score = score + 1
            else:
                matched = matched + "-"

    # some formatted output
    print("." * startpoint + matched)           
    print("." * startpoint + s2)
    print(s1)
    print(score) 
    print(" ")

    return score


def find_best_score(s1, s2, l1, l2):
    """
    Find the optimal alignment between two sequences.
    
    Tests all possible starting positions and returns the alignment 
    with the highest number of matching bases.
    
    Args:
        s1 : The longer sequence
        s2 : The shorter sequence
        l1 : Length of s1
        l2 : Length of s2

    Returns:
        Formatted alignment result
    """

    my_best_align = None
    my_best_score = -1

    for i in range(l1): # Note that you just take the last alignment with the highest score
        z = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
            my_best_align = "." * i + s2 # think about what this is doing!
            my_best_score = z 
    print(f"{my_best_align}\n{s1}\nBest score: {my_best_score}")
    result = f"{my_best_align}\n{s1}\nBest score: {my_best_score}"
    return result 

def main(argv):
    """
    Main function that orchestrates sequence alignment.
    
    Imports sequences, finds the best alignment, and saves the result 
    to ../results/aligned_seq.txt.
    
    Args:
        argv: Command line arguments (not currently used)
    
    Returns:
        int: Exit status (0 for success)
    """
    s1, s2, l1, l2 = import_values()
    with open( '../results/aligned_seq.txt', 'w') as f:
        f.write(find_best_score(s1, s2, l1, l2))    
    return(0)


if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)

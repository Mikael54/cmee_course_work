#!/usr/bin/env python3

"""
A code that finds the best allignent for two strands based on a csv file
"""

__appname__ = '[Align Sequences]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import csv


def import_values():
    """Imports the sequence data based on a csv and extracts ordered values, including lenght and sequence"""
    with open("../data/align_seq_sample.csv", "r") as file:
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
    """Calculate the match score based on a startpoint"""
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
    """Find the best allignment between sequences"""

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
    """Finds the best allignment and saves it to a text file"""
    s1, s2, l1, l2 = import_values()
    with open( '../results/aligned_seq.txt', 'w') as f:
        f.write(find_best_score(s1, s2, l1, l2))    
    return(0)


if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)

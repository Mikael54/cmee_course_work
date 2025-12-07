#!/usr/bin/env python3
"""
An example of various loops that print hello a variable number of times.
"""

__appname__ = '[Hello Functions]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'


################
def hello_1(x):
    """Print 'Hello' for every number divisible by 3 in range 0 to x-1."""
    for j in range(x):
        if j % 3 == 0:
            print('Hello')
    print(' ')
hello_1(12)


################
def hello_2(x):
    """Print 'Hello' for numbers where remainder is 3 when divided by 5 OR by 4."""
    for j in range(x):
        if j % 5 == 3:
            print('Hello')
        elif j % 4 == 3:
            print('Hello')
    print(' ')

hello_2(12)

#################

def hello_3(x, y):
    """Print 'Hello' for every number in the range from x to y-1."""
    for i in range(x, y):
        print('Hello')
    print(' ')

hello_3(3, 17)

def hello_4(x):
    """Print 'Hello' repeatedly, incrementing x by 3 each time until x equals 15."""
    while x != 15:
        print('Hello')
        x = x + 3
    print(' ')

hello_4(0)

def hello_5(x):
    """Print 'Hello' with special conditions: 7 times when x=31, once when x=18."""
    while x < 100:
        if x == 31:
            for k in range(7):
                print('Hello')
        elif x == 18:
            print('Hello')
        x = x + 1
    print(' ')

hello_5(12)

#################
# WHILE loop with BREAK
def hello_6(x, y):
    """Print 'hello!' with incrementing counter y, stopping when y reaches 6."""
    while x: # while x is True
        print("hello! " + str(y))
        y += 1 # increment y by 1 
        if y == 6:
            break
    print(' ')

hello_6 (True, 0)
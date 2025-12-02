#!/usr/bin/env python3

"""Some functions exemplifying the use of control statements"""
__appname__ = '[CF exercises 1]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'


import sys


def foo_1(x):
    """Returns the square root of the input."""
    if x < 0:
        return "Error: Cannot calculate square root of negative number"
    return x ** 0.5

def foo_2(x, y):
    """Returns the larger of two numbers."""
    if x > y:
        return x
    return y

def foo_3(x, y, z):
    """Returns of list of the three numbers in ascending order."""
    if x > y:
        x, y = y, x
    if x > z:
        x, z = z, x
    if y > z:
        y, z = z, y
    return [x, y, z]

def foo_4(x):
    """Calculate factorial of x using iteration."""
    if not isinstance(x, int):
        return "Error: Factorial requires an integer input"
    if x < 0:
        return "Error: Factorial not defined for negative numbers"

    result = 1
    for i in range(1, x+1):
        result = result * i
    return result

def foo_5(x):
    """Calculate factorial of x using recursion."""
    if not isinstance(x, int):
        return "Error: Factorial requires an integer input"
    if x < 0:
        return "Error: Factorial not defined for negative numbers"
    
    if x == 0 or x == 1:
        return 1
    if x == 1:
        return 1
    return x * foo_5(x-1)

def foo_6(x):
    """Calculate factorial of x using a while loop."""
    if not isinstance(x, int):
        return "Error: Factorial requires an integer input"
    if x < 0:
        return "Error: Factorial not defined for negative numbers"
    

    facto = 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return facto



def main(argv):
    """Run all example functions and print their results."""
    print(foo_1(10))
    print(foo_2(10, 2))
    print(foo_3(10, 2, 3))
    print(foo_4(10))
    print(foo_5(10))
    print(foo_6(10))
    return 0



if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
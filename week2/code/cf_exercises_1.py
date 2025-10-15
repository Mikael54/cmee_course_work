#!/usr/bin/env python3

"""Some functions exemplifying the use of control statements"""
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'


import sys


def foo_1(x):
    return x ** 0.5

def foo_2(x, y):
    if x > y:
        return x
    return y

def foo_3(x, y, z):
    if x > y:
        x, y = y, x
    if x > z:
        x, z = z, x
    if y > z:
        y, z = z, y
    return [x, y, z]

def foo_4(x):
    result = 1
    for i in range(1, x+1):
        result = result * i
    return result

def foo_5(x):
    if x == 1:
        return 1
    return x * foo_5(x-1)

def foo_6(x):
    facto = 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return facto


if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
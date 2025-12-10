#!/usr/bin/env python3
"""
Demonstrates error handling with try-except blocks to catch division by zero.
"""

__appname__ = '[Debugme]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'

def buggyfunc(x):
    """Demonstrates error handling for division by zero."""
    y = x
    for i in range(x):
        try: 
            y = y-1
            z = x/y
        except ZeroDivisionError:
            print(f"The result of dividing a number by zero is undefined")
        except:
            print(f"This didn't work;{x = }; {y = }")
        else:
            print(f"OK; {x = }; {y = }, {z = };")
    return z

buggyfunc(20)
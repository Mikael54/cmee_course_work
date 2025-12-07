#!/usr/bin/env python3
"""

Script to filter oak species from a list of tree taxa using various oak techniques.

"""

__appname__ = '[oaks]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'


# List of tree species
taxa = [ 'Quercus robur',
         'Fraxinus excelsior',
         'Pinus sylvestris',
         'Quercus cerris',
         'Quercus petraea',
       ]

def is_an_oak(name):
    """Check if a species name belongs to the oak genus (Quercus)."""
    return name.lower().startswith('quercus ')

##Using for loops
# Initialize empty set
oaks_loops = set()
# Loop through each species and add oaks to the set
for species in taxa:
    if is_an_oak(species):
        oaks_loops.add(species)
print(oaks_loops)

##Using list comprehension
oaks_lc = set([species for species in taxa if is_an_oak(species)])
print(oaks_lc)

# Using for loops to find oaks and convert to UPPER CASE
# Initialize empty set
oaks_loops = set()
for species in taxa:
    if is_an_oak(species):
        oaks_loops.add(species.upper())
print(oaks_loops)

## Get names in UPPER CASE using list comprehension
oaks_lc = set([species.upper() for species in taxa if is_an_oak(species)])
print(oaks_lc)

#!/usr/bin/env python3
"""
Script to extract Latin names, common names, and body masses 
from a tuple of bird species. 

This is done using both a loop and comprehensions.
"""

__appname__ = '[lc1]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'

# Input data: tuple of bird records in the form
# (Latin name, common name, mean body mass)
birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
         )

# Approach 1: List comprehension
# Initialize empty dictionary

latin_names = [row[0] for row in birds]
common_names = [row[1] for row in birds]
weights = [row[2] for row in birds]


print(f"The list comprehension approach:\n"
      f"Latin names:\n{latin_names}\n\n"
      f"Common names:\n{common_names}\n\n"
      f"Weights:\n{weights}\n")

# Approach 2: Loops
# Initialise empty lists
latin_names = []
common_names = []
weights = []

# Loop through each bird entry and unpack variables
for latin, common, weight in birds:
    latin_names.append(latin)
    common_names.append(common)
    weights.append(weight)

print(f"The loop approach:\n"
      f"Latin names:\n{latin_names}\n\n"
      f"Common names:\n{common_names}\n\n"
      f"Weights:\n{weights}\n")

 
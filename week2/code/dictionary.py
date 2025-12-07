#!/usr/bin/env python3
"""
Script to populate a dictionary mapping taxa so that it 
maps order names to sets of taxa and prints it to screen. 

This is done using both a loop and comprehensions.
"""

__appname__ = '[dictionary]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'

# Input data: list of tuples containing (species_name, order_name)
taxa = [ ('Myotis lucifugus','Chiroptera'),
         ('Gerbillus henleyi','Rodentia',),
         ('Peromyscus crinitus', 'Rodentia'),
         ('Mus domesticus', 'Rodentia'),
         ('Cleithrionomys rutilus', 'Rodentia'),
         ('Microgale dobsoni', 'Afrosoricida'),
         ('Microgale talazaci', 'Afrosoricida'),
         ('Lyacon pictus', 'Carnivora'),
         ('Arctocephalus gazella', 'Carnivora'),
         ('Canis lupus', 'Carnivora'),
        ]


# Approach 1: loop
# Initialize empty dictionary
taxa_dic = {}

# Iterate through each species-order pair
for species, order in taxa:
    # Check if this order already exists in the dictionary
    if order in taxa_dic:
        # If it exists, add the species to the existing set
        taxa_dic[order].add(species)
    else:
        # Order doesn't exist yet, so create a new set with this species
        taxa_dic[order] = set([species])

# Print the dictionary
print(f"The loop approach:\n{taxa_dic}\n")



# Approach 2: Using comprehensions
# Clear the dictionary 
taxa_dic = {}

# Extract all unique orders from the taxa list using a set comprehension
orders  = {order for species, order in taxa}

# Create a  comprehension that creates key-value pairs
# the value is a comprehension that finds all species belonging to that order
taxa_dic = {order: {species for species, order_2 in taxa if order_2 == order} for order in orders}

# Print the  dictionary
print(f"The comprehension approach):\n{taxa_dic}")
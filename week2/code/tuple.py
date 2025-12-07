#!/usr/bin/env python3
# Author: Mikael Ridza Minten mikael.minten25@imperial.ac.uk
# Script: tuple.py
# Description: Prints latin name, common name and mass of birds.
# Arguments: None.
# Date: Oct 2025


# Input data
birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
        )

# Loop through each bird and print three variables variables
for latin, common, weight in birds:
    print("Latin name:", latin, "Common name:", common, "Mass:", weight)
#!/usr/bin/env python3
"""

Filters rainfall data from 1910 using both list comprehensions and loops.

"""

__appname__ = '[lc1]'
__author__ = 'Mikael Minten (mikael.minten25@imperial.ac.uk)'
__version__ = '0.0.1'



# Average UK Rainfall (mm) for 1910 by month
# http://www.metoffice.gov.uk/climate/uk/datasets
rainfall = (('JAN',111.4),
            ('FEB',126.1),
            ('MAR', 49.9),
            ('APR', 95.3),
            ('MAY', 71.8),
            ('JUN', 70.2),
            ('JUL', 97.1),
            ('AUG',140.2),
            ('SEP', 27.0),
            ('OCT', 89.4),
            ('NOV',128.4),
            ('DEC',142.2),
           )

# (1) Use a list comprehension to create a list of month,rainfall tuples where
# the amount of rain was greater than 100 mm.
high_rainfall_comp = [(month, rain) for month, rain in rainfall if rain > 100]


# (2) Use a list comprehension to create a list of just month names where the
# amount of rain was less than 50 mm. 

low_rainfall_comp = [month for month, rain in rainfall if rain < 50]

# Print results
print(f"List comprehension approach:\n"
      f"Months and rainfall values when the amount of rain was greater than 100mm:\n{high_rainfall_comp}\n\n"
      f"Months with rainfall less than 50mm:\n{low_rainfall_comp}\n")


# (3) Now do (1) and (2) using conventional loops (you can choose to do 
# this before 1 and 2 !). 

# Initialise empty lists
high_rainfall = []
low_rainfall = []

# Loop through each month-rainfall pair
for month, rain in rainfall:
    if rain > 100:
        high_rainfall.append((month, rain))
    if rain < 50:
        low_rainfall.append(month)


# Print results from loop approach
print(f"Loop approach:\n"
      f"Months and rainfall values when the amount of rain was greater than 100mm:\n{high_rainfall}\n\n"
      f"Months with rainfall less than 50mm:\n{low_rainfall}\n")


   





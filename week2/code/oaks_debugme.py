import csv
import sys

import doctest # Import the doctest module

#Define function
def is_an_oak(name):
    """
    >>> is_an_oak('Fraxinus, excelsior')
    False

    >>> is_an_oak('quercus, robur') 
    True

    >>> is_an_oak('Quercus, robur') 
    True

    >>> is_an_oak('Quercuss, robur') 
    True
    
    """
    return name.lower().startswith('quercus')

def main(argv): 
    f = open('../data/test_oak_data.csv','r')
    g = open('../data/just_oak_data.csv','w') #doesnt w mean we write it??- should it not go to results- check with smraat tomorow?
    taxa = csv.reader(f)
    csvwrite = csv.writer(g)
    oaks = set()
    for row in taxa:
        print(row)
        print ("The genus is: ") 
        print(row[0] + '\n')
        if is_an_oak(row[0]):
            print('FOUND AN OAK!\n')
            csvwrite.writerow([row[0], row[1]])    

    return 0
    
#if (__name__ == "__main__"):
#    status = main(sys.argv)




doctest.testmod()
# Author: Mikael Minten
# Date: October 2025
# Script: apply_1.R
# Description: Demonstrates how apply function works.


## Build a random matrix
M <- matrix(rnorm(100), 10, 10)

## Take the mean of each row
RowMeans <- apply(M, 1, mean)
print (RowMeans)

RowVars <- apply(M, 1, var)
print (RowVars)

ColMeans <- apply(M, 2, mean)
print (ColMeans)
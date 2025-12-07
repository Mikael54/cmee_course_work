# Author: Mikael Minten
# Date: October 2025
# Script: vectorize_1.R
# Description: A script to demonstrate vectorization in R.

M <- matrix(runif(1000000), 1000, 1000)

SumAllElements <- function(M) {
    Dimensions <- dim(M)
    Tot <- 0
    for (i in 1:Dimensions[1]) {
        for (j in 1:Dimensions[2]) {
            Tot <- Tot + M[i,j]
        }
    }
    return (Tot)
}


print("Using loops, the time taken is:")
print(system.time(SumAllElements(M)))

print("Using the in-built vectorized function, the time taken is:")
print(system.time(sum(M))) 
# Author: Mikael Minten
# Date: October 2025
# Script: Break.R
# Description: A script to demonstrate how to use break in R loops.  


i <- 0 #Initialize i
    while (i < Inf) {
        if (i == 10) {
            break 
        } else { # Break out of the while loop!  
            cat("i equals " , i , " \n")
            i <- i + 1 # Update i
    }
}

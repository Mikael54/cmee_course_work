# Author: Mikael Minten
# Date: October 2025
# Script: Break.R
# Description: A script to demonstrate how to use break in R loops.  


i <- 0 #Initialize i
    while (i < Inf) { # This would loop forever without break
        if (i == 10) {
            break # Exit the loop when i reaches 10
        } else { # Break out of the while loop!  
            cat("i equals " , i , " \n")
            i <- i + 1 # Update i (increase by 1 each time)
    }
}

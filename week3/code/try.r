# Author: Mikael Minten
# Date: October 2025
# Script: try.r
# Description: Demonstrates error handling with the 'try' function in R.

# Function that samples data and calculates mean if sample is diverse enough
doit <- function(x) {
    temp_x <- sample(x, replace = TRUE) # Take a random sample with replacement
    if(length(unique(temp_x)) > 30) { # Check if sample has more than 30 unique values
         print(paste("Mean of this sample was:", as.character(mean(temp_x))))
        } 
    else {
        stop("Couldn't calculate mean: too few unique values!") # Throw an error
        }
    }


set.seed(1345) # Set random seed so results are reproducible

popn <- rnorm(50) # Create a population of 50 random numbers from normal distribution

#hist(popn) # Visualize the population


#lapply(1:15, function(i) doit(popn)) # Without try(), this would crash on errors


# Using try() to catch errors without stopping the entire loop
result <- lapply(1:15, function(i) try(doit(popn), FALSE)) # FALSE means don't print errors

class(result) # Check what type of object result is

result # View all results (including errors)

# Alternative approach: using a for loop with try()
result <- vector("list", 15) # Preallocate/Initialize an empty list
for(i in 1:15) {
    result[[i]] <- try(doit(popn), FALSE) # Store each result (or error) in the list
    }
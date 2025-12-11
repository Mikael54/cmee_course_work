# Author: Mikael Minten
# Date: October 2025
# Script: control_flow.R
# Description: illustrate the use of browser function.  

Exponential <- function(N0 = 1, r = 1, generations = 10) {
  # Runs a simulation of exponential growth
  # Returns a vector of length generations
  
  N <- rep(NA, generations)    # Creates a vector of NA
  
  N[1] <- N0 # Set the first population value
  for (t in 2:generations) {
    N[t] <- N[t-1] * exp(r) # Each generation = previous population * growth rate
    browser() # Pause here to inspect variables 
  }
  return (N)
}

plot(Exponential(), type="l", main="Exponential growth")
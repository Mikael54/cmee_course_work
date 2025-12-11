# Author: Mikael Minten
# Date: October 2025
# Script: control_flow.R
# Description: Demonstrates control flow tools.

# If-else statements
a <- TRUE
if (a == TRUE) {
    print ("a is TRUE")
} else {
    print ("a is FALSE") # This won't print because a is TRUE
}


z <- runif(1) ## Generate a uniformly distributed random number
if (z <= 0.5) {print ("Less than a half")}

# For loops
for (i in 1:10) {
    j <- i*i
    print(paste(i, "squared in", j)) # paste() combines text and numbers
}

for(species in c('Heliodoxa rubinoides', 
                 'Boissonneaua jardini', 
                 'Sula nebouxii')) {
      print(paste('The species is', species)) # Loop through each species name
}

v1 <- c("a","bc","def")
for (i in v1) {
    print(i)
}

# while loops

i <- 0
while (i < 10) {
    i <- i+1 # Increment i first
    print(i^2) # Then print the square
}
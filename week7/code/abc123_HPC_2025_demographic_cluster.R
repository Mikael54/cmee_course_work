# CMEE 2024 HPC exercises R code pro forma
# For stochastic demographic model cluster run

rm(list=ls()) # good practice 
source("Demographic.R")


iter <- as.numeric(Sys.getenv(“PBS_ARRAY_INDEX”))

set.seed(123) # set seeds needs to be the same as iter



# conditions
source("abc123_HPC_2025_main.R")

large_adult<- state_initialise_adult(4,100)
small_adult <- state_initialise_adult(4,10)

large_spread <- state_initialise_spread(4,100)
small_spread <- state_initialise_spread(4,10)

# run the simulation
## Load the functions from demographics.R

# save to a file


# remove object from the env



# logging in is done in the shell script
# write code cthat automatically loads the memory from the cluster too 
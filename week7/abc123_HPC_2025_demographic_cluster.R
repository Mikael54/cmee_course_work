# CMEE 2024 HPC exercises R code pro forma
# For stochastic demographic model cluster run

rm(list=ls()) # good practice 
graphics.off()

source("Demographic.R")
source("abc123_HPC_2025_main.R")


iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

set.seed(iter) # set seeds needs to be the same as iter

# initial conditions


if (iter <= 25) {
  initial_state <- state_initialise_adult(4, 100)
  condition_name <- "large_adult"
} else if (iter <= 50) {
  initial_state <- state_initialise_adult(4, 10)
  condition_name <- "small_adult"
} else if (iter <= 75) {
  initial_state <- state_initialise_spread(4, 100)
  condition_name <- "large_spread"
} else {
  initial_state <- state_initialise_spread(4, 10)
  condition_name <- "small_spread"
}


# Create filename for storing results
output_filename <- paste0("output_", condition_name, "_", iter, ".rda")


# run the simulation
clutch_distribution <- c(0.06,0.08,0.13,0.15,0.16,0.18,0.15,0.06,0.03)
growth_matrix <- matrix(c(0.1, 0.0, 0.0, 0.0,
                              0.5, 0.4, 0.0, 0.0,
                              0.0, 0.4, 0.7, 0.0,
                              0.0, 0.0, 0.25, 0.4),
    nrow=4, ncol=4, byrow=T)
reproduction_matrix <- matrix(c(0.0, 0.0, 0.0, 2.6,
                              0.0, 0.0, 0.0, 0.0,
                              0.0, 0.0, 0.0, 0.0,
                              0.0, 0.0, 0.0, 0.0),
    nrow=4, ncol=4, byrow=T)


results_list <- vector("list", 150)

for (i in 1:150) {
    results_list[[i]] <-stochastic_simulation(initial_state,
    growth_matrix,reproduction_matrix,clutch_distribution, 120)
}

save(results_list, file = output_filename)


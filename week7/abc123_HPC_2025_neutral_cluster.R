# CMEE 2024 HPC exercises R code pro forma
# For neutral model cluster run

rm(list=ls()) # good practice 

# turn off graphics
graphics.off()

# Load required functions
source("abc123_HPC_2025_main.R")

# Read job number from the cluster
iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

# set seed
set.seed(iter) # set seeds needs to be the same as iter


# set size
if (iter <= 25) {
  size <- 500
} else if (iter <= 50) {
  size <- 1000
} else if (iter <= 75) {
  size <- 2500
} else {
  size <- 5000
}

# setting the rest of the variables
speciation_rate <- 0.0062236

output_file_name <- paste0("neutral_sim_", iter, ".rda")

interval_rich <- 1

interval_oct <- size / 10

burn_in_generations <- 8 * size

wall_time <- 690

# Run the neutral simulation
neutral_cluster_run(size = size, 
                   speciation_rate = speciation_rate,
                   wall_time = wall_time,
                   interval_rich = interval_rich,
                   interval_oct = interval_oct,
                   burn_in_generations = burn_in_generations,
                   output_file_name = output_file_name)
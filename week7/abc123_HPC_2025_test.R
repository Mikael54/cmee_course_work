# CMEE 2024 HPC excercises R code HPC run code proforma

rm(list=ls()) # good practice 
source("abc123_HPC_2025_main.R")

question_2()
question_1()
question_8()
question_18()
question_5()


# it should take a faction of a second to source your file
# if it takes longer you're using the main file to do actual simulations
# it should be used only for defining functions that will be useful for your cluster run and which will be marked automatically

# do what you like here to test your functions (this won't be marked)
# for example
species_richness(c(1,4,4,5,1,6,1))


test<- species_abundance(c(1,5,3,6,5,6,1,1))
test
# should return 4 when you've written the function correctly for question 1

# you may also like to use this file for playing around and debugging
# but please make sure it's all tidied up by the time it's made its way into the main.R file or other files.


x<- 100
species_richness(init_community_min(x))
species_richness(init_community_max(x))


# 1699624


  for (generation in 1:duration) {
    community <- neutral_generation_speciation(community, speciation_rate)
    richness[generation + 1] <- length(unique(community))
  }





# testing the data:list


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

View(results_list)





# randominised initial state: 




init_community_max <- function(size){
  community <- seq(1, size)
  return(community)
  
}

# Question 9
init_community_min <- function(size){
    community <- rep(1, size)
  return(community)

} 

init_community_random <- function(size){
  community <- sample(1:size, size, replace = TRUE)
  return(community)
}









  rep = 50  

  community_max <- init_community_max(100)
  community_min <- init_community_min(100)
#create data frame for just max that has 'rep' columns
df_max <- data.frame(matrix(NA, nrow = 2201, ncol = rep))

  # Run 10 replicate time series for maximum diversity
  for (i in 1:rep) {
    df_max[,i] <- neutral_time_series_speciation(community_max, 0.1, 2200)
  }
  
 ci_max <- apply(df_max, 1, function(x) quantile(x, probs = c(0.014, 0.986)))
 
 df_max_summary <- data.frame(
   time = 0:2200,
   mean = rowMeans(df_max),
   ci_lower = ci_max[1, ],
   ci_upper = ci_max[2, ]
 )



time_series_repetition <- function(community, speciation_rate, duration, rep) {
   # Create data frame to store 'rep' columns
   df <- data.frame(matrix(NA, nrow = duration + 1, ncol = rep))
   
   # Run 'rep' replicate time series
   for (i in 1:rep) {
     df[, i] <- neutral_time_series_speciation(community, speciation_rate, duration)
   }
   
   df_summary <- data.frame(
     time = 0:duration,
     mean = rowMeans(df),
     ci_lower = apply(df, 1, function(x) quantile(x, probs = 0.014)),
     ci_upper = apply(df, 1, function(x) quantile(x, probs = 0.986))
   )

   return(df_summary)
}






start_time <- proc.time()

for (i in 1:100) {

  print(i)

  # time it using proc.time
}

  end_time <- proc.time()
  print(start_time)
  print(end_time)
  print(end_time - start_time)




# maybe check the time after each iteration?


# elapsed_time as a single vector
if (elapsed_time[3] > 0.05) {}


start_time <- proc.time()
elapsed_time <- proc.time() - start_time
count <- 0

while (elapsed_time[3] < 0.005) {
  count <- count + 1
  print(count)
  elapsed_time <- proc.time() - start_time
}
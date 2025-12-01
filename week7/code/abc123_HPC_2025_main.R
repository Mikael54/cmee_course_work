#HE MIGHT UPDATE THE DEMOGRAPHICS .R file SO MAKE SURE YOU AHVE IT INSTALLED!!!


# CMEE 2024 HPC exercises R code main pro forma
# You don't HAVE to use this but it will be very helpful.
# If you opt to write everything yourself from scratch please ensure you use
# EXACTLY the same function and parameter names and beware that you may lose
# marks if it doesn't work properly because of not using the pro-forma.

name <- "Mikael Ridza Minten"
preferred_name <- "Mikael"
email <- "mikael.minten25@imperial.ac.uk"
username <- "mm4725"

# Please remember *not* to clear the work space here, or anywhere in this file.
# If you do, it'll wipe out your username information that you entered just
# above, and when you use this file as a 'toolbox' as intended it'll also wipe
# away everything you're doing outside of the toolbox.  For example, it would
# wipe away any automarking code that may be running and that would be annoying!

# Section One: Stochastic demographic population model

# Question 0

state_initialise_adult <- function(num_stages,initial_size){
  state <- rep(0, num_stages)
  state[num_stages] <- initial_size
  return(state)
}

state_initialise_spread <- function(num_stages,initial_size){
  state <- rep(floor(initial_size / num_stages), num_stages)
  remainder <- initial_size %% num_stages
  
  if (remainder != 0) {
    state[1:remainder] <- floor(initial_size / num_stages) + 1
  }
  
  return(state)
}

# Question 1

source("Demographic.R")
library(ggplot2)

question_1 <- function(){
  # defining the matrix (do we define it within the function?)
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

  # population projections
  projection_matrix <- reproduction_matrix + growth_matrix
  adult_deterministic <-   deterministic_simulation(state_initialise_adult(4, 100),
    projection_matrix, 24)
  spread_deterministic <-  deterministic_simulation(state_initialise_spread(4, 100),
    projection_matrix, 24)

  #time vector
  time <- 0:24

  # plot
  
  df <- data.frame(
    time = time,
    adult = adult_deterministic,
    spread = spread_deterministic
  )

  adult_v_spread_plot <- ggplot() +
    geom_line(data = df, aes(x = time, y = adult, color = "Adult")) +
    geom_line(data = df, aes(x = time, y = spread, color = "Spread")) +
    labs(x = "\nTime step", y = "Population size\n", color = "Initial Condition") +
    scale_x_continuous(limits = c(0, 24), expand = c(0, 0)) +
    theme_bw() +
    theme(
    axis.text.x = element_text(size = 12),     # making the years at a bit of an angle
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),                        
      panel.grid = element_blank(),                                   # Removing the background grid lines               
      plot.margin = unit(c(1,1,1,1), units = , "cm"),                 # Adding a 1cm margin around the plot
      legend.text = element_text(size = 12, face = "italic"),         # Setting the font for the legend text
      legend.title = element_blank(),                                 # Removing the legend title
      legend.position = c(0.1, 0.9))                                 #

  png(filename="question_1", width = 600, height = 400)
  print(adult_v_spread_plot)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("All adults has initial quicker growth, then a crash, and then stable, seemingly linear growth - On the other HADNXYZ- TO FINISH ")
}
question_1()
# Question 2
question_2 <- function(){
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

  adult_stochastic <-   stochastic_simulation(state_initialise_adult(4, 100),
    growth_matrix,reproduction_matrix,clutch_distribution, 24)
  spread_stochastic <-   stochastic_simulation(state_initialise_spread(4, 100),
    growth_matrix,reproduction_matrix,clutch_distribution, 24)


  #time vector
  time <- 0:24

    df <- data.frame(
    time = time,
    adult = adult_stochastic,
    spread = spread_stochastic
  )

  stochastic_plot <- ggplot() +
    geom_line(data = df, aes(x = time, y = adult, color = "Adult")) +
    geom_line(data = df, aes(x = time, y = spread, color = "Spread")) +
    labs(x = "\nTime step", y = "Population size\n", color = "Initial Condition") +
    scale_x_continuous(limits = c(0, 24), expand = c(0, 0)) +
    theme_bw() +
    theme(
    axis.text.x = element_text(size = 12),     # making the years at a bit of an angle
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),                        
      panel.grid = element_blank(),                                   # Removing the background grid lines               
      plot.margin = unit(c(1,1,1,1), units = , "cm"),                 # Adding a 1cm margin around the plot
      legend.text = element_text(size = 12, face = "italic"),         # Setting the font for the legend text
      legend.title = element_blank(),                                 # Removing the legend title
      legend.position = c(0.1, 0.9))                                 #


  png(filename="question_2", width = 600, height = 400)
  # plot your graph here
  print(stochastic_plot)

  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}

question_2()

# Questions 3 and 4 involve writing code elsewhere to run your simulations on the cluster


# Question 5
question_5 <- function(){
  
  png(filename="question_5", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}

# Question 6
question_6 <- function(){
  
  png(filename="question_6", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}


# Section Two: Individual-based ecological neutral theory simulation 

# Question 7
species_richness <- function(community){
  
}

# Question 8
init_community_max <- function(size){
  
}

# Question 9
init_community_min <- function(size){
  
}

# Question 10
choose_two <- function(max_value){
  
}

# Question 11
neutral_step <- function(community){
  
}

# Question 12
neutral_generation <- function(community){
  
}

# Question 13
neutral_time_series <- function(community,duration)  {
  
}

# Question 14
question_8 <- function() {
  
  
  
  png(filename="question_14", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}

# Question 15
neutral_step_speciation <- function(community,speciation_rate)  {
  
}

# Question 16
neutral_generation_speciation <- function(community,speciation_rate)  {
  
}

# Question 17
neutral_time_series_speciation <- function(community,speciation_rate,duration)  {
  
}

# Question 18
question_18 <- function()  {
  
  png(filename="question_18", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}

# Question 19
species_abundance <- function(community)  {
  
}

# Question 20
octaves <- function(abundance_vector) {
  
}

# Question 21
sum_vect <- function(x, y) {
  if (length(x) > length(y)) {
    y <- c(y, rep(0,length(x) - length(y)))}
  if (length(y) > length(x)) {
    x <- c(x, rep(0,length(y) - length(x)))}
  return(x+y)
}


# if length of a is less than length of b- then ammend legth(a) - length(b)


# Question 22
question_22 <- function() {
  
  png(filename="question_22", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}

# Question 23
neutral_cluster_run <- function(speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, output_file_name) {
    
}

# Questions 24 and 25 involve writing code elsewhere to run your simulations on
# the cluster

# Question 26 
process_neutral_cluster_results <- function() {
  
  
  combined_results <- list() #create your list output here to return
  # save results to an .rda file
  
}

plot_neutral_cluster_results <- function(){

    # load combined_results from your rda file
  
    png(filename="plot_neutral_cluster_results", width = 600, height = 400)
    # plot your graph here
    Sys.sleep(0.1)
    dev.off()
    
    return(combined_results)
}


# Challenge questions - these are substantially harder and worth fewer marks.
# I suggest you only attempt these if you've done all the main questions. 

# Challenge question A
Challenge_A <- function(){
  
  png(filename="Challenge_A", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
}

# Challenge question B
Challenge_B <- function() {
  
  png(filename="Challenge_B", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
}

# Challenge question C
Challenge_B <- function() {
  
  png(filename="Challenge_C", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()

}

# Challenge question D
Challenge_D <- function() {
  
  png(filename="Challenge_D", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
}

# Challenge question E
Challenge_E <- function() {
  
  png(filename="Challenge_E", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}


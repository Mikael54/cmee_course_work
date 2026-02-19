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

state_initialise_adult <- function(num_stages, initial_size){
  state <- rep(0, num_stages)
  state[num_stages] <- initial_size
  return(state)
}

state_initialise_spread <- function(num_stages, initial_size){
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
  # defining the matrix
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
  adult_deterministic <- deterministic_simulation(state_initialise_adult(4, 100),
    projection_matrix, 24)
  spread_deterministic <- deterministic_simulation(state_initialise_spread(4, 100),
    projection_matrix, 24)

  # time vector
  time <- 0:24

  # plot
  
  df <- data.frame(
    time = time,
    adult = adult_deterministic,
    spread = spread_deterministic
  )

  adult_v_spread_plot <- ggplot() +
    geom_line(data = df, aes(x = time, y = adult, color = "Adult-only initialisation")) +
    geom_line(data = df, aes(x = time, y = spread, color = "Evenly spread initialisation")) +
    labs(title = "Effect of Initial Age Structure on Deterministic Population Time Series\n",
         x = "\nTime step", y = "Population size\n") +
    scale_x_continuous(limits = c(0, 24), expand = c(0, 0)) +
    theme_bw() +
    theme(
    axis.text.x = element_text(size = 12),     # making the years at a bit of an angle
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      panel.grid = element_blank(),                                   # Removing the background grid lines               
      plot.margin = unit(c(1, 1, 1, 1), units = "cm"),                 # Adding a 1cm margin around the plot
      legend.text = element_text(size = 12, face = "italic"),         # Setting the font for the legend text
      legend.title = element_blank(),                                 # Removing the legend title
      legend.position = c(0.2, 0.9))                                 #

  png(filename="question_1", width = 600, height = 400)
  print(adult_v_spread_plot)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("The adult-only initialization exhibits rapid initial growth, followed by a more pronounced crash and then a period of stable growth that closely resembles an exponential curve. The evenly spread initialization also shows early rapid growth, though to a lesser extent than the adult-only case. This is followed by a phase of stagnation or slight decline occurring at the same time step as the crash in the adult-only initialization. After this point, the population again follows the onset of exponential growth, but with population size consistently lagging behind that of the adult-only initialization.")
}

# Question 2
question_2 <- function(){
  clutch_distribution <- c(0.06, 0.08, 0.13, 0.15, 0.16, 0.18, 0.15, 0.06, 0.03)
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

  adult_stochastic <- stochastic_simulation(state_initialise_adult(4, 100),
    growth_matrix, reproduction_matrix, clutch_distribution, 24)
  spread_stochastic <- stochastic_simulation(state_initialise_spread(4, 100),
    growth_matrix, reproduction_matrix, clutch_distribution, 24)


  # time vector
  time <- 0:24

    df <- data.frame(
    time = time,
    adult = adult_stochastic,
    spread = spread_stochastic
  )

  stochastic_plot <- ggplot() +
    geom_line(data = df, aes(x = time, y = adult, color = "Adult-only initialisation")) +
    geom_line(data = df, aes(x = time, y = spread, color = "Evenly spread initialisation")) +
    labs(title = "Effect of Initial Age Structure on Stochastic Population Time Series\n",
         x = "\nTime step", y = "Population size\n") +
    scale_x_continuous(limits = c(0, 24), expand = c(0, 0)) +
    theme_bw() +
    theme(
    axis.text.x = element_text(size = 12),     # making the years at a bit of an angle
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      panel.grid = element_blank(),                                   # Removing the background grid lines               
      plot.margin = unit(c(1, 1, 1, 1), units = "cm"),                 # Adding a 1cm margin around the plot
      legend.text = element_text(size = 12, face = "italic"),         # Setting the font for the legend text
      legend.title = element_blank(),                                 # Removing the legend title
      legend.position = c(0.2, 0.9))                                 #


  png(filename="question_2", width = 600, height = 400)
  # plot your graph here
  print(stochastic_plot)

  Sys.sleep(0.1)
  dev.off()
  
  return("This mirrors the general trend observed in the previous deterministic simulation (i.e. initial rapid growth, followed by a crash or stagnation, and then more steady growth). However, the stochastic simulation is less smooth because it is driven by random chance. Over time, or across many simulations, these small random fluctuations are expected to average out, resulting in dynamics that more closely resemble the results from Question 1.")
}


# Questions 3 and 4 involve writing code elsewhere to run your simulations on the cluster


# Question 5
question_5 <- function(){
  
# Create counting vector
extinction_number <- c(small_adult = 0, large_adult = 0, small_spread = 0, large_spread = 0)

# Loop through files 1-100
for(i in 1:100) {
  
  # Determine parameter type and build file path based on number range
  if(i <= 25) {
    initial_state <- "large_adult"
    file_path <- paste0("output_large_adult_", i, ".rda")
  } else if(i <= 50) {
    initial_state <- "small_adult"
    file_path <- paste0("output_small_adult_", i, ".rda")
  } else if(i <= 75) {
    initial_state <- "large_spread"
    file_path <- paste0("output_large_spread_", i, ".rda")
  } else {
    initial_state <- "small_spread"
    file_path <- paste0("output_small_spread_", i, ".rda")
  }
  
    
    # Load the file
    load(file_path)
    
    # Loop through all 150 vectors in results_list
    for(j in 1:150) {
      
      # Check if this vector exists and has at least 121 elements
      if(min(results_list[[j]]) == 0) {
        extinction_number[initial_state] <- extinction_number[initial_state] + 1
      }
    }
  }

  proportion_extinct <-extinction_number/(25*150)

  df <- data.frame(
   initial_state = c("Small Adult", 
                    "Large Adult", 
                    "Small Spread", 
                    "Large Spread"),
  proportion = as.numeric(proportion_extinct)
)

  (richness_barplot <- ggplot(df, aes(x = initial_state, y = proportion)) +
    geom_bar(position = position_dodge(), stat = "identity", colour = "black", fill = "#00868B") +
    theme_bw() +
    labs(title = "Extinction Risk Across Population Size and Age Structure\n",
         x = "Initial Population State",
         y = "Proportion of Extinctions\n") +
    theme(axis.text.x = element_text(size = 12, angle = 45, vjust = 1, hjust = 1),  # Angled labels, so text doesn't overlap
          axis.text.y = element_text(size = 12),
          axis.title = element_text(size = 14, face = "plain"),
          plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
          panel.grid = element_blank(),                                          
          plot.margin = unit(c(1, 1, 1, 1), units = "cm")))


  png(filename="question_5", width = 600, height = 400)
  # plot your graph here
  print(richness_barplot)
  Sys.sleep(0.1)
  dev.off()
  
  return("The population most likely to go extinct is the small, evenly spread population, followed by the small adult-only population. This is primarily because smaller populations contain fewer individuals and are therefore more vulnerable to demographic stochasticity, where random events have a proportionally larger impact. In contrast, random fluctuations in larger populations are less significant at the individual level and tend to average out across many individuals, resulting in more stable, positive growth overall.

Small populations are more prone to extinction when individuals are evenly distributed across life stages, because immature individuals must first survive to adulthood before they can reproduce. This introduces additional stochasticity and delays population growth. By comparison, in an adult-only population, all individuals are immediately capable of reproduction, reducing the risk of extinction.")
}

# Question 6
question_6 <- function(){
  
  # matrices (same as Q1)
  growth_matrix <- matrix(c(0.1, 0.0, 0.0, 0.0,
                            0.5, 0.4, 0.0, 0.0,
                            0.0, 0.4, 0.7, 0.0,
                            0.0, 0.0, 0.25, 0.4),
                          nrow=4, ncol=4, byrow=TRUE)
  
  reproduction_matrix <- matrix(c(0.0, 0.0, 0.0, 2.6,
                                  0.0, 0.0, 0.0, 0.0,
                                  0.0, 0.0, 0.0, 0.0,
                                  0.0, 0.0, 0.0, 0.0),
                                nrow=4, ncol=4, byrow=TRUE)
  
  projection_matrix <- growth_matrix + reproduction_matrix



  # containers for summed population sizes
  small_spread_sum <- rep(0, 121)
  large_spread_sum <- rep(0, 121)


    # loop through files for initial conditions 3 and 4
  for(i in 51:100){
    
    if(i <= 75){
      file_path <- paste0("output_large_spread_", i, ".rda")
      type <- "large"
    } else {
      file_path <- paste0("output_small_spread_", i, ".rda")
      type <- "small"
    }
    
    load(file_path)
    
    # loop through simulations in each file
    for(j in 1:150){
      if(type == "large"){
        large_spread_sum <- large_spread_sum + results_list[[j]]
      } else {
        small_spread_sum <- small_spread_sum + results_list[[j]]
      }
    }
  }


  # mean stochastic population trends
  large_spread_mean <- large_spread_sum / 3750
  small_spread_mean <- small_spread_sum / 3750


    # deterministic simulations
  large_det <- deterministic_simulation(
    state_initialise_spread(4, 100),
    projection_matrix, 120)
  
  small_det <- deterministic_simulation(
    state_initialise_spread(4, 10),
    projection_matrix, 120)
  
  # deviation from deterministic model
  large_dev <- large_spread_mean / large_det
  small_dev <- small_spread_mean / small_det


  time <- 0:120
  
  df <- data.frame(
    time = time,
    small = small_dev,
    large = large_dev
  )

    deviation_plot <- ggplot() +
    geom_line(data=df, aes(x=time, y=small, colour="Small population")) +
    geom_line(data=df, aes(x=time, y=large, colour="Large population")) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "black", alpha = 0.5) +
    labs(
      title = "Deviation of Stochastic Population Time Series from Deterministic Model\n",
      x = "\nTime step",
      y = "Deviation from deterministic model\n",
      colour = "Population Type"
    ) +
    scale_x_continuous(limits = c(0, 120), expand = c(0, 0)) +
    theme_bw() +
    theme(
      axis.text.x = element_text(size = 12),
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14),
      plot.title = element_text(size = 14, hjust = 0.5),
      panel.grid = element_blank(),
      legend.title = element_text(size = 10),
      legend.text = element_text(size = 10, face = "italic"),
      legend.position = "right",
      plot.margin = unit(c(1, 1, 1, 1), units = "cm")
    )




  png(filename="question_6", width = 600, height = 400)
  # plot your graph here
  print(deviation_plot)
  Sys.sleep(0.1)
  dev.off()

  return("A deterministic model better approximates the average behaviour of a large population. This is evident from the large population values generally being closer to 1, indicating lower deviation. Small populations are more susceptible to stochasticity, whereas in large populations, random individual-level events are averaged out across many individuals. As a result, population dynamics in larger populations more closely align with the predictions of a deterministic model.")
}


# Section Two: Individual-based ecological neutral theory simulation 

# Question 7
species_richness <- function(community){
  return(length(unique(community)))
}

# Question 8
init_community_max <- function(size){
  community <- seq(1, size)
  return(community)
  
}

# Question 9
init_community_min <- function(size){
    community <- rep(1, size)
  return(community)

}

# Question 10
choose_two <- function(max_value){
  result <- sample(1:max_value, size = 2, replace = FALSE)
  return(result)
}

# Question 11
neutral_step <- function(community){
  individuals <- choose_two(length(community))
  
  # individual at the first index dies and is replaced
  # by a copy of the individual at the second index
  community[individuals[1]] <- community[individuals[2]]
  
  return(community)
}

# Question 12
neutral_generation <- function(community) {
  x <- length(community)

  # if the size is odd
  if (x %% 2 == 1) {
    # 50% chance to round up or down
    if (runif(1) < 0.5) {
      generation_size <- floor(x / 2)
    } else {
      generation_size <- ceiling(x / 2)
    }
  } else {
    generation_size <- x / 2
  }

  for (i in 1:generation_size) {
    community <- neutral_step(community)
  }

  return(community)
}

# Question 13
neutral_time_series <- function(community, duration) {
  richness <- vector("numeric", duration + 1)
  
  # Record initial species richness
  richness[1] <- species_richness(community)
  
    # Simulate over generations
  for (generation in 1:duration) {
    community <- neutral_generation(community)
    richness[generation + 1] <- species_richness(community)
  }
  
  return(richness)
}

# Question 14
question_8 <- function() {
  
  community <- init_community_max(100)

  richness_time_series <- neutral_time_series(community, 200)

    time <- 0:200

    df <- data.frame(
    time = time,
    richness = richness_time_series
  )

  richness_plot <- ggplot() +
    geom_line(data = df, aes(x = time, y = richness)) +
    labs(title = "Species Richness Time Series Under Neutral Theory Without Speciation\n",
         x = "\nGeneration", y = "Species Richness\n") +
    scale_x_continuous(limits = c(0, 200), expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    theme_bw() +
    theme(
    axis.text.x = element_text(size = 12),     # making the years at a bit of an angle
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      panel.grid = element_blank(),                                   # Removing the background grid lines               
      plot.margin = unit(c(1, 1, 1, 1), units = "cm"))                 # Adding a 1cm margin around the plot
      
  
  png(filename="question_14", width = 600, height = 400)
  # plot your graph here
  print(richness_plot)

  Sys.sleep(0.1)
  dev.off()
  
  return("This system will always tend towards domination by a single species. This is because the only process modelled is a death–replacement mechanism (neutral step), in which individuals are removed and replaced at random. Under these conditions, the only lasting change in community composition occurs through species extinctions. Given sufficient time, random fluctuations will lead to the extinction of all but one species."  
)
}

# Question 15
neutral_step_speciation <- function(community, speciation_rate) {
  
  if (runif(1) < speciation_rate) {
    # which individual will die
    dead_indiv <- sample(1:length(community), 1)

    # Assign a new unique species ID
    new_species <- max(community) + 1
    community[dead_indiv] <- new_species

  } else {
    # Otherwise, perform a normal neutral step
    community <- neutral_step(community)
  }

  return(community)
}




# Question 16
neutral_generation_speciation <- function(community, speciation_rate) {
    x <- length(community)

  # if the size is odd
  if (x %% 2 == 1) {
    # 50% chance to round up or down
    if (runif(1) < 0.5) {
      generation_size <- floor(x / 2)
    } else {
      generation_size <- ceiling(x / 2)
    }
  } else {
    generation_size <- x / 2
  }

  for (i in 1:generation_size) {
    community <- neutral_step_speciation(community, speciation_rate)
  }

  return(community)
}

# Question 17
neutral_time_series_speciation <- function(community, speciation_rate, duration) {
  richness <- vector("numeric", duration + 1)

  # Record initial species richness
  richness[1] <- length(unique(community))

  # Simulate over generations
  for (generation in 1:duration) {
    community <- neutral_generation_speciation(community, speciation_rate)
    richness[generation + 1] <- length(unique(community))
  }

  return(richness)
}

# Question 18
question_18 <- function()  { 

  # Two different initial conditions
  community_max <- init_community_max(100)
  community_min <- init_community_min(100)

  # Run time series with speciation
  richness_max <- neutral_time_series_speciation(community_max, 0.1, 200)
  richness_min <- neutral_time_series_speciation(community_min, 0.1, 200)

  time <- 0:200

  df <- data.frame(
    time = time,
    maximum_richness = richness_max,
    minimum_richness = richness_min
  )

  (richness_plot <- ggplot() +
      geom_line(data = df, aes(x = time, y = maximum_richness, colour = "Maximum diversity initialisation")) +
      geom_line(data = df, aes(x = time, y = minimum_richness, colour = "Minimum diversity initialisation")) +
      labs(title = "Species Richness Time Series Under Neutral Theory with Speciation\n",
           x = "\nGeneration", y = "Richness\n") +
      scale_x_continuous(limits = c(0, 200), expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      theme_bw() +
      theme(
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14, face = "plain"),
        plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
        panel.grid = element_blank(),
        plot.margin = unit(c(1, 1, 1, 1), units = "cm"),       legend.text = element_text(size = 12, face = "italic"),         # Setting the font for the legend text
        legend.title = element_blank(),                                 # Removing the legend title
        legend.position = c(0.23, 0.9))                                 #

      )

  png(filename = "question_18", width = 600, height = 400)
  print(richness_plot)
  Sys.sleep(0.1)
  dev.off()

  
  return("In this model, the initial conditions do not affect the long-term outcome, as both communities fluctuate around the same dynamic equilibrium given sufficient time. On average, when community richness is below this stable state, speciation dominates over extinction, leading to an increase in richness. Conversely, when richness exceeds this threshold, extinction plays a larger role than speciation, causing richness to decline.")
}

# Question 19
species_abundance <- function(community)  {
  abundance <- sort(table(community), decreasing = TRUE) # get abundance in decreasing order
  return(as.vector(abundance)) # return as vector
}

# Question 20
octaves <- function(abundance_vector) {
  # Find which octave class each abundance is part of
  octave_classes <- floor(log2(abundance_vector)) + 1
  
  # Count number of species in each class
  octave_counts <- tabulate(octave_classes)
  
  return(octave_counts)
}

# Question 21
sum_vect <- function(x, y) {
  if (length(x) > length(y)) {
    y <- c(y, rep(0, length(x) - length(y)))}
  if (length(y) > length(x)) {
    x <- c(x, rep(0, length(y) - length(x)))}
  return(x+y)
} # if length of a is less than length of b- then ammend legth(a) - length(b)


# Question 22
question_22 <- function() {
  
  # Two different initial conditions
  community_max <- init_community_max(100)
  community_min <- init_community_min(100)


# maximum community
  for (generation in 1:2200) {
    community_max <- neutral_generation_speciation(community_max, 0.1)

    # record the abundance vector every 20 generations starting from generation 200
    if (generation %% 20 == 0 && generation >= 200) {
      abundance_vector_max <- species_abundance(community_max)
      octave_vector_max <- octaves(abundance_vector_max)
    # combine each observation into a single vector
      if (generation == 200) {
        combined_octave_max <- octave_vector_max
      } else {
        combined_octave_max <- sum_vect(combined_octave_max, octave_vector_max)
      }
    }
  }
  
  # Calculate average by dividing sum by 101 observations (generations 200-2200, every 20)
  combined_octave_max <- combined_octave_max / 101

  # minimum community
  for (generation in 1:2200) {
    community_min <- neutral_generation_speciation(community_min, 0.1)

    # record the abundance vector every 20 generations starting from generation 200
    if (generation %% 20 == 0 && generation >= 200) {
      abundance_vector_min <- species_abundance(community_min)
      octave_vector_min <- octaves(abundance_vector_min)
    # combine each observation into a single vector
      if (generation == 200) {
        combined_octave_min <- octave_vector_min
      } else {
        combined_octave_min <- sum_vect(combined_octave_min, octave_vector_min)
      }
    }
  }
  
  # Calculate average by dividing sum by 101 observations (generations 200-2200, every 20)
  combined_octave_min <- combined_octave_min / 101

  # Create tidy format data frame
  df <- data.frame(
    octave = c(1:length(combined_octave_max), 1:length(combined_octave_min)),
    mean_species_abundance = c(combined_octave_max, combined_octave_min),
    initialization = c(rep("Maximum diversity initialisation", length(combined_octave_max)),
                      rep("Minimum diversity initialisation", length(combined_octave_min)))
  )

# Plot the results as a bar graph for both octaves
  (octave_plot <- ggplot(df, aes(x = octave, y = mean_species_abundance, fill = initialization)) +
      geom_bar(stat = "identity") +
      facet_wrap(~ initialization, ncol = 2) +
      labs(title = "Species Abundance Distribution\n",
           x = "\nAbundance Octave", y = "Number of Species\n") +
      scale_x_continuous(breaks = 1:max(df$octave)) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
      theme_bw() +
      theme(
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
        axis.title = element_text(size = 14, face = "plain"),
        panel.grid = element_blank(),
        plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
        strip.text = element_text(size = 12, face = "italic"),  # Facet panel labels
        legend.position = "none")                               # Remove legend since facet labels show it

      )



  png(filename="question_22", width = 600, height = 400)
  print(octave_plot)
  Sys.sleep(0.1)
  dev.off()
  
  return("The initial conditions do not effect the species abundance distribution after the burn in period. This is because, similar to the previous question 18, the system reaches a dynamic equilibrium where the strength of speciation and extinction are similar.")
}

# Question 23
neutral_cluster_run <- function(speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, output_file_name) {
    


  
  # create minimum community
  community <- init_community_min(size)

  start_time <- proc.time()
  elapsed_time <- proc.time() - start_time

  generation <- 1

  time_series <- numeric()
  abundance_list <- list()

  while (elapsed_time[3] < wall_time*60) {
    community <- neutral_generation_speciation(community, speciation_rate)

    if (generation <= burn_in_generations && generation %% interval_rich == 0) {
    # measure the richness
    time_series <- c(time_series, species_richness(community))
    }

    if (generation %% interval_oct == 0) {
      # measure the octaves
      abundance_list[[length(abundance_list) + 1]] <- octaves(species_abundance(community))
    }

    generation <- generation + 1

    elapsed_time <- proc.time() - start_time
  }

  total_time <- elapsed_time[[3]] / 60  # total time in minutes
  
  # save the results to an .rda file
  save(time_series, abundance_list, community, total_time,
       speciation_rate, size, wall_time, interval_rich, interval_oct,
       burn_in_generations, file = output_file_name)
}

# Questions 24 and 25 involve writing code elsewhere to run your simulations on
# the cluster

# Question 26 
process_neutral_cluster_results <- function() {
  
  sizes <- c(500, 1000, 2500, 5000)
  sum_list <- list(0, 0, 0, 0)
  count_list <- list(0, 0, 0, 0)
  
  # Get all results
  files <- list.files(pattern = "neutral_sim_.*\\.rda")
  
  for (f in files) {
    # Load the data: time_series, abundance_list, size, burn_in_generations, interval_oct
    load(f)
    
    # catagorise the size
    size_index <- which(sizes == size)
    
    # Calculate how many entries to skip (burn-in period)
    post_burn_octaves <- abundance_list[(burn_in_generations / interval_oct + 1):length(abundance_list)]
      # Sum the octaves for this simulation
      for (oct in post_burn_octaves) {
        # sum_vect is a helper to add vectors of unequal length by padding with zeros
        sum_list[[size_index]] <- sum_vect(sum_list[[size_index]], oct)
        count_list[[size_index]] <- count_list[[size_index]] + 1
      }
    
  }

  # Calculate averages
  combined_results <- list()
  for (i in 1:4) {
    combined_results[[i]] <- sum_list[[i]] / count_list[[i]]
  }
  
  # Save the data
  save(combined_results, file = "combined_results.rda")
  return(combined_results)
}
  


plot_neutral_cluster_results <- function(){

    # load combined_results from your rda file
    load("combined_results.rda")

  sizes <- c("Size: 500", "Size: 1000", "Size: 2500", "Size: 5000")
  plot_data <- data.frame()
  
  # Loop through the 4 result vectors
  for (i in 1:4) {
    temp_df <- data.frame(
      Octave = seq(1, length(combined_results[[i]])),
      Abundance = combined_results[[i]],
      Size = sizes[i]
    )
    # Stack it onto the main table
    plot_data <- rbind(plot_data, temp_df)
  }

  # create levels for size factor
  plot_data$Size <- factor(plot_data$Size, levels = sizes)

  max_octave <- max(sapply(combined_results, length))

  # create a bar plot for all sizes
  (bar_plot <- ggplot(plot_data, aes(x = Octave, y = Abundance)) +
      facet_wrap(~ Size, ncol = 2) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = "Community Size And Species Abundance Distribution\n",
         x = "\nAbundance Octave", y = "Number of Species\n") +
    scale_x_continuous(breaks = 1:max_octave) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
      theme_bw() +
      theme(
        strip.text = element_text(size = 12),
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14, face = "plain"),
        plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
        panel.grid = element_blank(),
        plot.margin = unit(c(1, 1, 1, 1), units = "cm")))

  
    png(filename="plot_neutral_cluster_results", width = 600, height = 400)
    print(bar_plot)
    Sys.sleep(0.1)
    dev.off()
    
    return(combined_results)
}


# Challenge questions - these are substantially harder and worth fewer marks.
# I suggest you only attempt these if you've done all the main questions. 

# Challenge question A
Challenge_A <- function(){
  
  # Pre allocate the data frame for better performance
  time_steps <- 0:120
  n_total_rows <- 100 * 150 * length(time_steps)
  row_idx <- 1  # Track where to insert next chunk
  sim_id <- 1   #

  # Pre-allocate the entire data frame
  population_size_df <- data.frame(
    simulation_number = integer(n_total_rows),
    initial_condition = character(n_total_rows),
    time_step = integer(n_total_rows),
    population_size = numeric(n_total_rows),
    stringsAsFactors = FALSE
  )

  # Loop through files 1–100
  for (i in 1:100) {

    # Determine initial condition and file path
    if (i <= 25) {
      initial_state <- "large adult"
      file_path <- paste0("output_large_adult_", i, ".rda")

    } else if (i <= 50) {
      initial_state <- "small adult"
      file_path <- paste0("output_small_adult_", i, ".rda")

    } else if (i <= 75) {
      initial_state <- "large mixed"
      file_path <- paste0("output_large_spread_", i, ".rda")

    } else {
      initial_state <- "small mixed"
      file_path <- paste0("output_small_spread_", i, ".rda")
    }

    # Load results_list
    load(file_path)

    # Loop through the 150 simulations in this file
    for (j in 1:150) {

      pop_ts <- results_list[[j]]

      # Calculate the range of rows to fill
      end_idx <- row_idx + length(time_steps) - 1

      # Fill in the pre-allocated rows
      population_size_df$simulation_number[row_idx:end_idx] <- sim_id
      population_size_df$initial_condition[row_idx:end_idx] <- initial_state
      population_size_df$time_step[row_idx:end_idx] <- time_steps
      population_size_df$population_size[row_idx:end_idx] <- pop_ts
      
      row_idx <- end_idx + 1
      sim_id <- sim_id + 1
    }
  }

  # Plot all time series
  p <- ggplot(population_size_df,
              aes(x = time_step,
                  y = population_size,
                  group = simulation_number,
                  colour = initial_condition)) +
    geom_line(alpha = 0.1) +
    labs(
      title = "Stochastic Population Time Series Across Initial Conditions\n",
      x = "\nTime step",
      y = "Population size\n",
      colour = "Initial condition"
    ) +
      scale_x_continuous(expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      guides(colour = guide_legend(override.aes = list(alpha = 1, linewidth = 1.5))) +
      theme_bw() +
      theme(
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
    axis.text.x = element_text(size = 12),     # making the years at a bit of an angle
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),                        
      panel.grid = element_blank(),                                   # Removing the background grid lines               
      plot.margin = unit(c(1, 1, 1, 1), units = "cm"),                 # Adding a 1cm margin around the plot
      legend.text = element_text(size = 12, face = "italic"),         # Setting the font for the legend text
      legend.title = element_blank(),                                 # Removing the legend title
      legend.position = c(0.15, 0.8))                                 #


  png(filename="Challenge_A", width = 600, height = 400)
  # plot your graph here
  print(p)
  Sys.sleep(0.1)
  dev.off()
  

  return(population_size_df)

}


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

# Challenge question B
Challenge_B <- function() {
  
  # Create data frame to store 10 replicates for both max and min

  rep <- 50

  community_max <- init_community_max(100)
  community_min <- init_community_min(100)


   df_max <- time_series_repetition(community_max, 0.1, 100, rep)
   df_min <- time_series_repetition(community_min, 0.1, 100, rep)


  # Function to detect equilibrium
  detect_equilibrium <- function(df, window = 12, threshold = 0.1) {
    for (i in (window + 1):nrow(df)) {
      # Calculate rolling mean for current and previous windows
      current_mean <- mean(df$mean[(i - window + 1):i])
      previous_mean <- mean(df$mean[(i - window):(i - 1)])
      
      # Check if change is below threshold
      if (abs(current_mean - previous_mean) < threshold) {
        return(df$time[i])
      }
    }
    return(NA)
  }
  
  # Detect equilibrium for both conditions
  equil_max <- detect_equilibrium(df_max)
  equil_min <- detect_equilibrium(df_min)
  

  # Take the later of the two (when both have equilibrated)
  equilibrium_generation <- max(equil_max, equil_min, na.rm = TRUE)


# putting it into one dataframe for plotting
df_summary <- rbind(
  data.frame(df_max, initialization = "Maximum diversity initialisation"),
  data.frame(df_min, initialization = "Minimum diversity initialisation")
)

  (richness_plot_CI <- ggplot() +
      geom_line(data = df_summary, aes(x = time, y = mean, colour = initialization)) +
      geom_ribbon(data = df_summary, aes(x = time, ymin = ci_lower, ymax = ci_upper, fill = initialization), alpha = 0.2) +
      labs(title = "Species Richness with 97.2% Confidence Intervals\n",
           x = "\nGeneration", y = "Species Richness\n") +
      # add a line at equilibrium generation
      geom_vline(xintercept = equilibrium_generation, linetype = "dashed", colour = "black") +
      annotate("text", x = equilibrium_generation+2, y = 45, label = paste("Dynamic Equilibrium"), size = 3, hjust = 0, angle = 90) +
      scale_x_continuous(expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      theme_bw() +
      theme(
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14, face = "plain"),
        plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
        panel.grid = element_blank(),
        plot.margin = unit(c(1, 1, 1, 1), units = "cm"),       legend.text = element_text(size = 12, face = "italic"),         # Setting the font for the legend text
        legend.title = element_blank(),                                 # Removing the legend title
        legend.position = c(0.23, 0.9))                                 #

      )



  png(filename="Challenge_B", width = 600, height = 400)
  print(richness_plot_CI)
  Sys.sleep(0.1)
  dev.off()

  return(paste("The system reaches dynamic equilibrium after approximately", 
               equilibrium_generation, "generations."))
  
}


init_community_random_richness <- function(size, richness) {
   community <- sample(1:richness, size, replace = TRUE)
   return(community)
}

time_series_repetition_random_start <- function(community_size, richness, speciation_rate, duration, rep) {
   # Create data frame to store 'rep' columns
   df <- data.frame(matrix(NA, nrow = duration + 1, ncol = rep))
   
   # Run 'rep' replicate time series
   for (i in 1:rep) {
     community <- init_community_random_richness(community_size, richness)
     df[, i] <- neutral_time_series_speciation(community, speciation_rate, duration)
   }
   
   df_summary <- data.frame(
     time = 0:duration,
     mean = rowMeans(df)
     )

   return(df_summary)
}


# Challenge question C
Challenge_C <- function() {
  
  # create different richness levels for initial communities
  richness_levels <- c(1, 20, 40, 60, 80, 100)
  rep <- 5 
  
  # Create a list to save all the results
  results_list <- list()
  
  # Loop through each richness level
  for (i in 1:length(richness_levels)) {
    # Use time series repetition function to get mean and save it to list
    results_list[[i]] <- time_series_repetition_random_start(100, richness_levels[i], 0.1, 150, rep)
  }
  

df_all <- do.call(rbind, lapply(1:length(richness_levels), function(i) {
  data.frame(results_list[[i]], 
             initialization = factor(richness_levels[i],
                                   levels = richness_levels))
}))


 (richness_plot_CI <- ggplot() +
      geom_line(data = df_all, aes(x = time, y = mean, colour = initialization)) +
      labs(title = "Species Richness Time Series from Different Richness Levels\n",
           x = "\nGeneration", y = "Richness\n", colour = "Initial Richness") +
      scale_x_continuous(expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      theme_bw() +
      theme(
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14, face = "plain"),
        plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
        panel.grid = element_blank(),
        plot.margin = unit(c(1, 1, 1, 1), units = "cm"),       
        legend.text = element_text(size = 9, face = "italic"),         # Setting the font for the legend text
        legend.title = element_text(size = 11),                                 # Removing the legend title
        legend.position = "right")                                 #

      )


  png(filename="Challenge_C", width = 600, height = 400)
  print(richness_plot_CI)
  Sys.sleep(0.1)
  dev.off()
}

# Challenge question D
Challenge_D <- function() {

  all_sizes <- c(500, 1000, 2500, 5000)
  size_labels <- c("Size: 500", "Size: 1000", "Size: 2500", "Size: 5000")
  
  # Create lists to store the sum of richness and number of simulations per size
  richness_sum <- list(numeric(), numeric(), numeric(), numeric())
  sim_count <- c(0, 0, 0, 0)
  
  files <- list.files(pattern = "neutral_sim_.*\\.rda")
  
  for (f in files) {
    load(f)
    size_index <- which(all_sizes == size)
    
    richness_sum[[size_index]] <- sum_vect(richness_sum[[size_index]], time_series)
    sim_count[size_index] <- sim_count[size_index] + 1
  }
  
  # Prepare data for ggplot
  plot_data <- data.frame()
  
  for (i in 1:4) {
    if (sim_count[i] > 0) {
      mean_richness <- richness_sum[[i]] / sim_count[i]
      
      temp_df <- data.frame(
        # Generations = index * interval (since interval_rich was 1, it's just the index)
        Generation = seq_along(mean_richness),
        Richness = mean_richness,
        Size = factor(size_labels[i], levels = size_labels)
      )
      plot_data <- rbind(plot_data, temp_df)
    }
  }
  
  # Create the plot
  (rich_plot <- ggplot(plot_data, aes(x = Generation, y = Richness)) +
    geom_line(linewidth = 0.5) +
    facet_wrap(~ Size, ncol = 2, scales = "free") +
    labs(title = "Mean Species Richness Time Series Across Community Sizes\n",
         x = "\nSimulation Generation", 
         y = "Mean Species Richness\n") +
    theme_bw() +
    theme(
      strip.text = element_text(size = 12),
      axis.text.x = element_text(size = 12),     # making the years at a bit of an angle
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      panel.grid = element_blank(),                                   # Removing the background grid lines               
      plot.margin = unit(c(1, 1, 1, 1), units = "cm"),                 # Adding a 1cm margin around the plot
    ))

  png(filename="Challenge_D", width = 600, height = 400)
  print(rich_plot)
  Sys.sleep(0.1)
  dev.off()

}



# Challenge question E
Challenge_E <- function() {
  
  # set parameters
  community_sizes <- c(500, 1000, 2500, 5000)
  v <- 0.0062236  
  reps_per_size <- 25 

  # Track total time for coalescence
  start_time <- Sys.time()
  
  # Store results for each community size
  octave_results <- list()


  for (size_idx in 1:length(community_sizes)) {
    J <- community_sizes[size_idx]
    
    # Store octaves for this size across all reps
    octave_list <- list()
  
  
    for (rep in 1:reps_per_size) {
      # Initialise a vector lineages of length J with 1 in every entry
      lineages <- rep(1, J)
      # Initialise an empty vector abundances (of length 0).
      abundances <- numeric(0)
      # Initialise a number N=J
      N <- J
      # Calculate theta, where theta = v(J-1)/(1-v).
      theta <- v * (J - 1) / (1 - v)
    
      while (N > 1) {
        # Choose an index j for the vector lineages at random according to a uniform distribution.
        j <- sample(1:N, 1)  # FIXED: was 1:J
        # Pick a random (decimal, not integer) number randnum between 0 and 1 (with a uniform distribution).
        randnum <- runif(1)
        # if randnum < theta/(theta + N - 1), then:
        if (randnum < theta / (theta + N - 1)) {
          # add the value in lineages[j] to the vector abundances
          abundances <- c(abundances, lineages[j])
        } else {
        # choose another index i for the vector lineages at random, but do not allow i=j. Then set lineages[i] <- lineages[i] + lineages[j].
        i <- sample(setdiff(1:N, j), 1)
        lineages[i] <- lineages[i] + lineages[j]
        }
      # Remove lineages[j] from lineages so that the lineages vector is now one shorter.
      lineages <- lineages[-j]
      # Decrease N by one so that N still gives the length of the lineages vector.
      N <- N - 1
    }
    # Once N=1, add the only element left in lineages to the end of abundances.
    abundances <- c(abundances, lineages)
    octave_list[[rep]] <- octaves(abundances)
  }
  

      # Average the octave vectors for this community size
    max_length <- max(sapply(octave_list, length))
    octave_matrix <- matrix(0, nrow = reps_per_size, ncol = max_length)
    
    for (i in 1:reps_per_size) {
      octave_matrix[i, 1:length(octave_list[[i]])] <- octave_list[[i]]
    }
    
    octave_results[[size_idx]] <- colMeans(octave_matrix)  

  }


    # Calculate total time for coalescence
  time <- difftime(Sys.time(), start_time, units = "hours")
  
  # Load cluster simulation results from question 26
  load("combined_results.rda")
  
  # Create data frame for coalescence results
  df_coalescence_list <- list()
  for (i in 1:length(community_sizes)) {
    df_coalescence_list[[i]] <- data.frame(
      octave = seq_along(octave_results[[i]]),
      species_count = octave_results[[i]],
      size = paste("Size:", community_sizes[i]),
      method = "Coalescence"
    )
  }
  df_coalescence <- do.call(rbind, df_coalescence_list)
  
  # Create data frame for cluster results
  df_cluster_list <- list()
  for (i in 1:length(community_sizes)) {
    df_cluster_list[[i]] <- data.frame(
      octave = seq_along(combined_results[[i]]),
      species_count = combined_results[[i]],
      size = paste("Size:", community_sizes[i]),
      method = "Cluster"
    )
  }
  df_cluster <- do.call(rbind, df_cluster_list)
  
  # Combine both data frames
  df_all <- rbind(df_coalescence, df_cluster)
  
  # Convert size to factor with correct order
  df_all$size <- factor(df_all$size, 
                        levels = paste("Size:", community_sizes))
  
  # Convert method to factor with correct order
  df_all$method <- factor(df_all$method, 
                          levels = c("Coalescence", "Cluster"))
  
  # Create plot with bars side by side for each octave
  (octave_plot <- ggplot(df_all, aes(x = octave, y = species_count, fill = method)) +
    facet_wrap(~ size, ncol = 2) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = "Community Size And Species Abundance of\nCoalescence and Cluster Simulations\n",
         x = "\nAbundance Octave", 
         y = "Number of Species\n",
         fill = "Simulation Type") +
    scale_x_continuous(breaks = seq(0, max(df_all$octave), by = 1)) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
    theme_bw() +
    theme(
      strip.text = element_text(size = 12),
      axis.text.x = element_text(size = 12),
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      panel.grid = element_blank(),
      plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
      legend.text = element_text(size = 12, face = "italic"),
      legend.title = element_text(size = 12),
      legend.position = "right"))
  



  png(filename="Challenge_E", width = 600, height = 400)
  print(octave_plot)
  Sys.sleep(0.1)
  dev.off()

  return(paste("Coalescence used", round(time, 4), "CPU hours while the cluster used", 100*12, "hours for the same amount of simulations.",
               "Coalescence is faster because it works backwards from present to past. This means that it is always at equilibrium and does not spend computing power simulating species that will not persist to the end of the simulation"))
}


# Author: Mikael Minten
# Date: October 2025
# Description: This script creates a figure and gets a p value for the warming in florida over the 20th century.

# Clear workspace
rm(list=ls())

# Check and load required packages
if (!require(tidyverse, quietly = TRUE)) {
    stop("Error: tidyverse package not installed (includes ggplot2, dplyr, etc.).\n",
         "       Please install with: install.packages('tidyverse')")
}

# Load required library
library(tidyverse)

# Check if data file exists
if (!file.exists("../data/key_west_annual_mean_temperature.RData")) {
    stop("Error: File '../data/key_west_annual_mean_temperature.RData' not found. Please check the file path.")
}

# Load temperature data for Key West
load("../data/key_west_annual_mean_temperature.RData")


# Performs permutation test by randomly shuffling temperature data and calculating correlations
# Args:
#   df: dataframe containing Year and Temp columns
#   number_of_permutation: number of permutation iterations to perform
# Returns: vector of correlation coefficients from permuted data
permutation <- function(df, number_of_permutation){
    # Initialize vector to store correlation coefficients
    cof_result <- vector(, number_of_permutation)

    # Loop through each permutation
    for(i in 1:number_of_permutation) {
    # Calculate correlation between Year and randomly shuffled Temp values
        cof_result[i]<- cor(df$Year, sample(df$Temp, nrow(df), replace = FALSE))
    }
    return(cof_result)
 }


# Function: calc_p_value
# Calculates p-value by comparing observed correlation to permutation distribution
# Args:
#   sequential_cof: observed correlation coefficient from actual data
#   permutation_cof: vector of correlation coefficients from permutations
# Returns: p-value (ratio of permutations greater than observed)
calc_p_value <- function(sequential_cof, permutation_cof) {
    # Initialize counters
    greater_than <- 0
    less_than <- 0

    # Count how many permutation correlations are greater/less than observed
    for(i in 1:length(permutation_cof)) {
        if (permutation_cof[i] > sequential_cof) {
            greater_than <- greater_than + 1 
        } else { 
            less_than <- less_than + 1
        }
    }

    # Return p-value based off a ratio
    return(greater_than/less_than) 
}

# Calculate observed correlation between Year and Temperature
sequential_cof <-cor(ats$Year, ats$Temp)

# Generate permutation distribution with 100,000 iterations
permutation_cof <- permutation(ats, 100000)

# Calculate and print p-value
calc_p_value(sequential_cof, permutation_cof)


# Making a figure

(p <- ggplot(ats, aes(x = Year, y = Temp)) +
  geom_point(color = I("black"), size = I(2)) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", fullrange = TRUE) +
  labs(
    title = "Annual Temperature in Florida
    Between 1900 and 2000\n",
    x = "\nYear",
    y = "Temperature (°C)\n"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5, 
                              margin = margin(b = 15)),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(20, 20, 20, 20)
  ))


# Exporting that figure

ggsave("../results/temperature_plot.pdf", 
       plot = p, 
       width = 8, 
       height = 6, 
       device = "pdf")



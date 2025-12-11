# Author: Mikael Minten
# Date: October 2025
# Script: tree_heights.R
# Description: A script to calculate tree heights based on distance and angle.


# This function calculates heights of trees given distance of each tree 
# from its base and angle to its top, using  the trigonometric formula 
#
# height = distance * tan(radians)
#
# ARGUMENTS
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
#
# OUTPUT
# The heights of the tree, same units as "distance"


if (!require("tidyverse", quietly = TRUE)) {
  stop("Please install the 'tidyverse' package")
}

library(tidyverse)

# Check if data file exists
if (!file.exists("../data/trees.csv")) {
    stop("Error: File '../data/trees.csv' not found. Please check the file path.")
}

tree_data <- read.csv("../data/trees.csv", header = TRUE)

# Check if data was loaded successfully
if (nrow(tree_data) == 0) {
    stop("Error: trees.csv appears to be empty.")
}

# Check for required columns
required_cols <- c("Angle.degrees", "Distance.m")
if (!all(required_cols %in% colnames(tree_data))) {
    stop("Error: Required columns missing in data. Expected: ", 
         paste(required_cols, collapse = ", "))
}

tree_height <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return (height)
}

tree_data <- tree_data %>%
    mutate(Tree.Height.m = tree_height(Angle.degrees, Distance.m))

write.csv(tree_data, "../results/tree_hts.csv", row.names = FALSE)

# This script should work using either source or Rscript in Linux / UNIX.
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

require("tidyverse") # check if tidyverse is installed- if not give an error 

tree_height <- function(degrees, distance) {
    radians <- degrees * pi /180
    height <- distance * tan(radians)
    return (height)
}

tree_data <- read.csv("../data/trees.csv", header = TRUE)

tree_data <- tree_data %>%
    mutate(Tree.Height.m = tree_height(Angle.degrees, Distance.m))

write.csv(tree_data, "../results/tree_hts.csv", row.names = FALSE)

# This script should work using either source or Rscript in Linux / UNIX.
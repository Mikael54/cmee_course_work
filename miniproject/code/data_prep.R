# ====================================================================
# Data Preparation Script for Growth Analysis
# ====================================================================
# Purpose: Clean and preprocess growth data for analysis
# Input: logistic_growth_data.csv, logistic_growth_meta_data.csv
# Output: data_clean.csv
# ====================================================================


# Load required libraries
require("tidyverse")


# ====================================================================
# Function Definitions
# ====================================================================

#' Load data files
#'
#' @param data_path Path to the growth data CSV file
#' @param metadata_path Path to the metadata CSV file
#' @return List containing data and metadata data frames
load_data <- function(data_path, metadata_path) {
  data <- read.csv(data_path, header = TRUE)
  metadata <- read.csv(metadata_path, header = TRUE)
  
  return(list(data = data, metadata = metadata))
}


#' Standardize column names to lowercase
#'
#' @param data Data frame
#' @param metadata Metadata frame
#' @return List containing data and metadata with lowercase column names
standardize_column_names <- function(data, metadata) {
  colnames(data) <- tolower(colnames(data))
  colnames(metadata) <- tolower(colnames(metadata))
  
  return(list(data = data, metadata = metadata))
}


#' Clean and transform growth data
#'
#' @param data Raw data frame
#' @param min_points Minimum number of data points required per dataset
#' @return Cleaned data frame
clean_growth_data <- function(data, min_points = 6) {
  # NOTE: I probably dont have to actually add a logged data- sing I use just logged 10 _popbio
  data_clean <- data %>%
    # remove anything with pobio less than 0 or time less than 0
    filter(popbio > 0, time > 0) %>%
    # remove the Time_units collumn since it is all the same
    select(-time_units) %>%
    # create a new collumn that is a unique identifier for each dataset, both with and without temperature
    mutate(
      id_no_temp = paste(species, medium, citation, sep = "_"),
      id_temp = paste(species, medium, citation, temp, sep = "_"),
      id_num = as.numeric(factor(id_temp)),
      id_num_no_temp = as.numeric(factor(id_no_temp))
    ) %>%
    # create a new collumn that is log transformed of popbio and time
    mutate(
      log_popbio = log(popbio),
      log_time = log(time),
      log10_popbio = log10(popbio),
      log10_time = log10(time)
    ) %>%
    # remove any datasets with less than 6 data points
    group_by(id_num) %>%
    filter(n() >= min_points) %>%
    ungroup()
  
  return(data_clean)
}


#' Save cleaned data to CSV file
#'
#' @param data_clean Cleaned data frame
#' @param output_path Path to save the CSV file
save_cleaned_data <- function(data_clean, output_path) {
  write.csv(data_clean, output_path, row.names = FALSE)
}


# ====================================================================
# Main Execution
# ====================================================================

main <- function() {
  # Load required data while considering that there are collumn names
  datasets <- load_data('../data/logistic_growth_data.csv', 
                        '../data/logistic_growth_meta_data.csv')
  
  # make all collumns lower case
  datasets <- standardize_column_names(datasets$data, datasets$metadata)
  
  # clean the data
  data_clean <- clean_growth_data(datasets$data)
  
  # export in the results folder
  save_cleaned_data(data_clean, '../results/data_clean.csv')
}

# Run main function
main()
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
  # Check if data file exists
  if (!file.exists(data_path)) {
    stop(paste("Error: Data file not found at", data_path))
  }
  
  # Check if metadata file exists
  if (!file.exists(metadata_path)) {
    stop(paste("Error: Metadata file not found at", metadata_path))
  }
  
  # Read data file
  data <- read.csv(data_path, header = TRUE)
  
  # Read metadata file
  metadata <- read.csv(metadata_path, header = TRUE)
  
  # Check if data files are empty
  if (nrow(data) == 0) {
    stop("Error: Data file is empty")
  }
  
  if (nrow(metadata) == 0) {
    warning("Warning: Metadata file is empty")
  }
  
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
  # Validate input data
  if (!is.data.frame(data)) {
    stop("Error: Input must be a data frame")
  }
  
  if (nrow(data) == 0) {
    stop("Error: Input data frame is empty")
  }
  
  # Check for required columns
  required_cols <- c("popbio", "time", "time_units", "species", "medium", "citation", "temp")
  missing_cols <- setdiff(required_cols, colnames(data))
  
  if (length(missing_cols) > 0) {
    stop(paste("Error: Missing required columns:", paste(missing_cols, collapse = ", ")))
  }
  
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
  
  # Check if any data remains after filtering
  if (nrow(data_clean) == 0) {
    stop("Error: No data remaining after cleaning and filtering")
  }
  
  return(data_clean)
}


#' Save cleaned data to CSV file
#'
#' @param data_clean Cleaned data frame
#' @param output_path Path to save the CSV file
save_cleaned_data <- function(data_clean, output_path) {
  # Validate input
  if (!is.data.frame(data_clean)) {
    stop("Error: Input must be a data frame")
  }
  
  if (nrow(data_clean) == 0) {
    warning("Warning: Attempting to save an empty data frame")
  }
  
  # Create output directory if it doesn't exist
  output_dir <- dirname(output_path)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    message(paste("Created output directory:", output_dir))
  }
  
  # Write the file
  write.csv(data_clean, output_path, row.names = FALSE)
  message(paste("Successfully saved cleaned data to:", output_path))
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
  
  message("Data preparation completed successfully!")
}

# Run main function
main()
#!/usr/bin/env Rscript

# Script to read all CSV files from ../data/processed_tables/
# Check column names and combine files with matching columns
# Add a 'site' column identifier extracted from filenames

#clear workspace
rm(list = ls())

# Load required libraries
library(readr)
library(purrr)
library(tidyverse)

# Creating functions for cleaning and filtering data ----
# Function to clean and standardize species names
clean_species_names <- function(df) {
  df <- df %>%
    mutate(
      # Convert to lowercase
      Species = tolower(Species),
      # Replace spaces with underscores
      Species = gsub(" ", "_", Species),
      # Remove rows with Homo sapiens (any variant)
      Species = ifelse(grepl("^homo_sapien", Species), NA, Species)
    ) %>%
    # Remove rows where Species is NA (including removed Homo sapiens)
    filter(!is.na(Species))
  
  cat(sprintf("Removed Homo sapiens entries\n"))
  cat(sprintf("Standardized species names to lowercase with underscores\n"))
  
  return(df)
}

# Function to filter only mammals
filter_mammals_only <- function(df) {
  # List of non-mammal species to remove (birds, etc.)
  non_mammals <- c(
    "phasianus_colchicus",     # Common Pheasant (bird)
    "columba_palumbus",        # Wood Pigeon (bird)
    "aix_galericulata",        # Mandarin Duck (bird)
    "buteo_buteo",             # Common Buzzard (bird)
    "coloeus_monedula",        # Western Jackdaw (bird)
    "garrulus_glandarius",     # Eurasian Jay (bird)
    "strix_aluco",             # Tawny Owl (bird)
    "turdus_philomelos"        # Song Thrush (bird)
  )
  
  # Filter out non-mammals
  df_mammals <- df %>%
    filter(!tolower(Species) %in% non_mammals)
  
  n_removed <- nrow(df) - nrow(df_mammals)
  cat(sprintf("Removed %d non-mammal records\n", n_removed))
  cat(sprintf("Remaining records: %d (mammals only)\n", nrow(df_mammals)))
  
  return(df_mammals)
}

# Helper function to convert columns to appropriate types
convert_column_types <- function(df) {
  # Try to convert columns to appropriate types
  # Keep character columns that should stay as character
  
  # Columns that should likely be numeric
  numeric_candidates <- c("delta.time.secs", "delta.time.mins", 
                          "delta.time.hours", "delta.time.days", "n_images")
  
  for (col in names(df)) {
    if (col %in% numeric_candidates) {
      df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
    }
  }
  
  # Try to parse date/time columns - handle multiple formats
  if ("DateTimeOriginal" %in% names(df)) {
    tryCatch({
      # Define possible datetime formats
      datetime_formats <- c(
        "%Y:%m:%d %H:%M:%S",     # Format: 2025:10:09 07:03:00
        "%d/%m/%Y %H:%M",        # Format: 09/10/2025 07:03
        "%Y/%m/%d %H:%M",        # Format: 2025/10/25 20:15
        "%Y-%m-%dT%H:%M:%SZ"     # Format: 2025-11-02T15:55:41Z (ISO 8601)
      )
      
      # Initialize with all NAs
      parsed_dt <- rep(as.POSIXct(NA), nrow(df))
      
      # Try each format and fill in successful parses
      for (fmt in datetime_formats) {
        temp_parse <- as.POSIXct(df$DateTimeOriginal, format = fmt, tz = "UTC")
        # Fill in values that were successfully parsed and are currently NA in result
        parsed_dt[is.na(parsed_dt) & !is.na(temp_parse)] <- 
          temp_parse[is.na(parsed_dt) & !is.na(temp_parse)]
      }
      
      if (!all(is.na(parsed_dt))) {
        df$DateTimeOriginal <- parsed_dt
      }
    }, error = function(e) {
      # Keep as character if parsing fails
      NULL
    })
  }
  
  if ("Date" %in% names(df)) {
    tryCatch({
      # Define possible date formats
      date_formats <- c(
        "%Y-%m-%d",     # ISO format
        "%d/%m/%Y",     # UK format: 09/10/2025
        "%m/%d/%Y"      # US format: 10/09/2025
      )
      
      # Initialize with all NAs
      parsed_date <- rep(as.Date(NA), nrow(df))
      
      # Try each format and fill in successful parses
      for (fmt in date_formats) {
        temp_parse <- as.Date(df$Date, format = fmt)
        # Fill in values that were successfully parsed and are currently NA in result
        parsed_date[is.na(parsed_date) & !is.na(temp_parse)] <- 
          temp_parse[is.na(parsed_date) & !is.na(temp_parse)]
      }
      
      # Also try to extract date from DateTimeOriginal if Date is still NA
      if ("DateTimeOriginal" %in% names(df) && sum(is.na(parsed_date)) > 0) {
        # If DateTimeOriginal was successfully parsed, extract dates
        if (inherits(df$DateTimeOriginal, "POSIXct")) {
          date_from_dt <- as.Date(df$DateTimeOriginal)
          parsed_date[is.na(parsed_date) & !is.na(date_from_dt)] <- 
            date_from_dt[is.na(parsed_date) & !is.na(date_from_dt)]
        }
      }
      
      if (!all(is.na(parsed_date))) {
        df$Date <- parsed_date
      }
    }, error = function(e) {
      # Keep as character if parsing fails
      NULL
    })
  }
  
  return(df)
}

# Function to read and combine CSV files with site identification
combine_csv_files <- function(data_dir = "../data/camera_trap/") {
  
  # Get all CSV files in the directory
  csv_files <- list.files(path = data_dir, 
                          pattern = "\\.csv$", 
                          full.names = TRUE)
  
  if (length(csv_files) == 0) {
    stop(paste("No CSV files found in", data_dir))
  }
  
  cat(sprintf("Found %d CSV files\n", length(csv_files)))
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  # Read all CSV files and store with metadata
  data_list <- lapply(csv_files, function(file_path) {
    # Extract site name from filename (remove path and .csv extension)
    site_name <- tools::file_path_sans_ext(basename(file_path))
    
    tryCatch({
      # Read the CSV file - read all columns as character first to avoid type conflicts
      df <- read_csv(file_path, show_col_types = FALSE, col_types = cols(.default = "c"))
      
      # Remove numbered index column if it exists (e.g., "...1" or similar)
      # This column is typically an auto-generated row number from R/Python
      if ("...1" %in% colnames(df)) {
        df <- df %>% select(-`...1`)
        cat(sprintf("Processed: %s - %d rows, %d columns (removed index column)\n", 
                    site_name, nrow(df), ncol(df)))
      } else {
        cat(sprintf("Processed: %s - %d rows, %d columns\n", 
                    site_name, nrow(df), ncol(df)))
      }
      
      # Add site column
      df <- df %>% mutate(site = site_name)
      
      return(df)
    }, error = function(e) {
      cat(sprintf("Error reading %s: %s\n", file_path, e$message))
      return(NULL)
    })
  })
  
  # Remove NULL entries (files that failed to read)
  data_list <- data_list[!sapply(data_list, is.null)]
  
  if (length(data_list) == 0) {
    stop("No CSV files could be read successfully")
  }
  
  cat("\n", paste(rep("=", 60), collapse = ""), "\n")
  
  # Combine all dataframes
  combined_df <- bind_rows(data_list)
  
  # Convert columns to appropriate types
  combined_df <- convert_column_types(combined_df)
  
  cat(sprintf("✓ Combined dataset: %d total rows\n", nrow(combined_df)))
  cat(sprintf("✓ Sites included: %d\n", n_distinct(combined_df$site)))
  cat(sprintf("✓ Columns: %d\n", ncol(combined_df)))
  
  return(combined_df)
}

# Run the function when script is sourced or executed
if (!interactive()) {
  combined_data <- combine_csv_files()
  cat("\n✓ Process complete!\n")
}

# Running to functions to identify just mammals and clean species names ----

combined_data <- combine_csv_files()

#summary(as.factor(combined_data$Date))
#summary(as.factor(combined_data$))
#colnames(combined_data)


clean_data <- clean_species_names(combined_data)
mammals_data <- filter_mammals_only(clean_data)

# write mammals data to CSV
write_csv(mammals_data,
          file = "../results/mammals_data.csv")



only_na_dates <- mammals_data %>%
  filter(is.na(Date))

# export only NA dates to CSV for checking
write_csv(only_na_dates,
          file = "../results/only_na_dates.csv")

# remove domestic_dog from the dataset
mammals_data <- mammals_data %>%   
filter(Species != "domestic_dog",
         Species != "canis_familiaris")


# Identify just muntjac records----
# identify just muntjac
muntjac_records <- species_by_date_station %>%
  filter(Species == "muntiacus_reevesi") 

muntjac_records_small <- muntjac_records %>%
  filter(n_records < 20)


hist(muntjac_records_small$n_records)
hist(log(muntjac_records_small$n_records))



# Summary statistics ----
# Convert site and Species to factors
mammals_data <- mammals_data %>%
  mutate(
    Station = as.factor(site),
    Species = as.factor(Species),
    Date = as.Date(Date)
  )

# Summary 1: Species counts per Station
species_by_station <- mammals_data %>% 
  group_by(site, Species) %>%
  summarise(n_records = n(), .groups = 'drop') %>%
  arrange(site, desc(n_records))

print("Species counts by Station:")
print(species_by_station)

# species count by station
species_tot_by_station <- mammals_data %>% 
  group_by(site) %>%
  summarise(n_records = n(), .groups = 'drop') %>%
  arrange(site, desc(n_records))

print("Species total by Station:")
print(species_tot_by_station)


# unique species count by station
species_unique_by_station <- mammals_data %>% 
  group_by(site) %>%
  summarise(n_records = n_distinct(Species), .groups = 'drop') %>%
  arrange(site, desc(n_records))

print("Species unique by Station:")
print(species_unique_by_station)

# signtings per species;
species_sightings <- mammals_data %>%
  group_by(Species) %>%
  summarise(n_records = n(), .groups = 'drop') %>%
  arrange(desc(n_records))

print("Total sightings per Species:")
print(n = 30, species_sightings)

# Summary 2: Date variation per Station
date_by_station <- mammals_data %>%
  group_by(Station) %>%
  summarise(
    n_records = n(),
    n_species = n_distinct(Species),
    first_date = min(Date, na.rm = TRUE),
    last_date = max(Date, na.rm = TRUE),
    n_days = as.numeric(difftime(max(Date, na.rm = TRUE), 
                                  min(Date, na.rm = TRUE), 
                                  units = "days")),
    .groups = 'drop'
  ) %>%
  arrange(Station)

print("\nDate variation by Station:")
print(date_by_station)

# Summary 3: Species counts by Date and Station
species_by_date_station <- mammals_data %>%
  group_by(Date, Station, Species) %>%
  summarise(n_records = n(), .groups = 'drop') %>%
  arrange(Date, Station, Species)

print("\nSpecies records by Date and Station:")
print(head(species_by_date_station, 20))




# export species records by date and station to CSV
write_csv(species_by_date_station,
          file = "../results/species_by_date_station.csv")


write_csv(muntjac_records,
          file = "../results/muntjac_records.csv")

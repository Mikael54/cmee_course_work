# Preamble on the purpose of this file:


# Load required libraries
require("tidyverse")


# Load required data while considering that there are collumn names
data <- read.csv('../data/logistic_growth_data.csv', header = TRUE)
metadata <- read.csv('../data/logistic_growth_meta_data.csv', header = TRUE)

# make all collumns lower case
colnames(data) <- tolower(colnames(data))
colnames(metadata) <- tolower(colnames(metadata))

# NOTE: I probably dont have to actually add a logged data- sing I use just logged 10 _popbio
# clean the data
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
  filter(n() >= 6) %>%
  ungroup()


  # export in the results folder
write.csv(data_clean, '../results/data_clean.csv', row.names = FALSE)
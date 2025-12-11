
library(camtrapR)
library(taxize)
library(overlap)
rm(list = ls())

# renaming images to be more informative:
imageRename(
  inDir = "../sandbox/camera_02_97_2025/raw_species",
  outDir = "../sandbox/camera_02_97_2025/species_renamed",
  hasCameraFolders = FALSE,      # Images are directly in the folder
  keepCameraSubfolders = FALSE,
  copyImages = TRUE
)


# check that the species exist
checkSpeciesNames(speciesNames = "Muntiacus reevesi",
searchtype = 'scientific')

# create a table
sp_table = recordTable(inDir = "../sandbox/camera_02_97_2025/species_renamed",
IDfrom = "directory", minDeltaTime = 30,
deltaTimeComparedTo = "lastIndependentRecord")



# STEP 2: READING ALL THE TABLES!
list.of.files = list.files("../data/camera_trap_tables", full.names = TRUE)
sp_table = read.csv(list.of.files[1])
for (i in 2:length(list.of.files)){temp_table = read.csv(list.of.files[i]) 
sp_table = rbind(sp_table, temp_table)
}


# NEXT STEP - I HAVE TO ANSWER THIS QUESTION??
# Now that you have the camera trap data, we can start looking for patterns. Create a
# table of all the camera trap records using recordTable():
# What do the minDeltaTime and deltaTimeComparedTo arguments mean, and why
# these are important when analysing camera trap data?
record_table <- recordTable(
  recordTable = sp_table,
  stationCol = "Station",
  speciesCol = "Species",
  dateTimeCol = "DateTimeOriginal"
)

head(record_table)


# how would I do this in radian??:
# You can navigate through the different species’ graphs by pressing the backwards and
# forwards bottom in RStudio’s viewer window. What does the density on the y-axis
# mean?


# get the correct date:allSpecies
library(lubridate)

# The formats we've observed are:
# 1. "YYYY-MM-DD HH:MM:SS" (e.g., 2025-10-25 16:46:29) -> "%Y-%m-%d %H:%M:%S"
# 2. "DD/MM/YYYY HH:MM:SS" (e.g., 03/11/2025 11:28:56) -> "%d/%m/%Y %H:%M:%S"
# 3. "DD/MM/YYYY HH:MM" (e.g., 03/11/2025 11:28) -> "%d/%m/%Y %H:%M"

# Use parse_date_time to try all likely formats.
sp_table$DateTimeOriginal <- parse_date_time(
  sp_table$DateTimeOriginal,
  orders = c("Ymd HMS", "dmy HMS", "dmy HM"),
  tz = "UTC" # Specify a timezone, for consistency (e.g., UTC)
)


# species activity density:
activityDensity(sp_table, allSpecies = TRUE)
unique(sp_table$Spec)


# activity overlap:
activityOverlap(sp_table, speciesA = "species_of_interest_A", speciesB = "species_of_interest_B")



# another question!
# Using the table you made with
#recordTable(), create a new table with the species richness per site

# Load epicollect:
read_csv("../data/sensor_sites_2025.csv")

detection_dataframe = merge(species_richness_dataframe,
epicollect_dataframe, by=c("column_name_detection_dataframe"="column_name_epicollect"))


# another question: After you have merges the dataframes, compare the species richness between the
# different habitat types, and make a simple plot to visualise it.

# spatial methods: https://imperialcollegelondon.github.io/living_planet_eco_evo_data/gis-practical/
# This webpage provides one long self-paced practical that 
# provides an introduction to key spatial data handling and 
# analysis techniques for use with the Ecological and Evolutionary Data Science.
#  This practical uses the R programming language to load, manipulate and 
# analyse spatial data. See more here on why we use R for GIS.
# https://imperialcollegelondon.github.io/living_planet_eco_evo_data/gis-practical/


# Resources: https://r.geocompx.org/
# 


# Libraries----
library(terra)       # core raster GIS package
library(sf)          # core vector GIS package
library(rcartocolor) # plotting
library(rpart)


# Sensor datasets----
# Load the data from the CSV file
sensor_locations <- read.csv("../data/SpatialMethods/SensorSites/form-1__setup.csv")

# Convert to an sf object by setting the fields containing X and Y data and set 
# the projection of the dataset
sensor_locations <- st_as_sf(
  sensor_locations, 
  coords=c("long_Sensor_location","lat_Sensor_location"),
  crs="EPSG:4326"
)

nest_boxes <- st_read("../data/SpatialMethods/NestBoxes/NestBoxes.shp")
print(head(nest_boxes))


nhm_aerial <- rast('../data/SpatialMethods/aerial/nhm_aerial.tiff')
silwood_aerial <- rast('../data/SpatialMethods/aerial/silwood_aerial.tiff')

print(nhm_aerial)

# Load the DTM data from ASC format files
silwood_dtm_SU96NE <- rast("../data/SpatialMethods/dtm_5m/SU96NE.asc")
silwood_dtm_SU96NW <- rast("../data/SpatialMethods/dtm_5m/SU96NW.asc")
nhm_dtm_TQ27NE <- rast("../data/SpatialMethods/dtm_5m/TQ27NE.asc")
nhm_dtm_TQ28SE <- rast("../data/SpatialMethods/dtm_5m/TQ28SE.asc")

# Look at the object data
silwood_dtm_SU96NE


# Set the projection information for the DTM datasets
crs(silwood_dtm_SU96NE) <- crs(silwood_dtm_SU96NW) <- "EPSG:27700"
crs(nhm_dtm_TQ27NE) <- crs(nhm_dtm_TQ28SE) <- "EPSG:27700"

# Print the modified dataset
silwood_dtm_SU96NE
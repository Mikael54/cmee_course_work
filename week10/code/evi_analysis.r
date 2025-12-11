# clear workspace
rm(list = ls())

library(terra)
library(sf)
library(dplyr)

# Load the sensor locations CSV
sensor_locations_df <- read.csv("../data/sensor_sites/form-1__setup.csv")

sensor_locations <- read.csv("../data/sensor_sites/form-1__setup.csv")

# Convert to sf object with WGS84 coordinates
sensor_locations <- st_as_sf(
  sensor_locations, 
  coords = c("long_Sensor_location", "lat_Sensor_location"),
  crs = "EPSG:4326"
)

# Convert sensor locations to BNG (EPSG:27700)
#sensor_locations <- st_transform(sensor_locations, crs = "EPSG:27700")

# Load the four 10m Sentinel-2 bands for Silwood
s2_silwood_10m <- rast(
  c(
    "../data/sentinel_2/R10m/silwood/T30UXC_20250711T110651_B02_10m.tiff",
    "../data/sentinel_2/R10m/silwood/T30UXC_20250711T110651_B03_10m.tiff",
    "../data/sentinel_2/R10m/silwood/T30UXC_20250711T110651_B04_10m.tiff",
    "../data/sentinel_2/R10m/silwood/T30UXC_20250711T110651_B08_10m.tiff"
  )
) / 10000

names(s2_silwood_10m) <- c("B", "G", "R", "NIR")

# ---- Calculate EVI for Silwood ----
evi_silwood <- 2.5 * 
  (s2_silwood_10m[["NIR"]] - s2_silwood_10m[["R"]]) / 
  (s2_silwood_10m[["NIR"]] + 
    6 * s2_silwood_10m[["R"]] - 
    7.5 * s2_silwood_10m[["B"]] + 1)

# Rename the band
names(evi_silwood) <- "EVI"

# Remove anomalous EVI values
evi_silwood[evi_silwood > 1 | evi_silwood < -1] <- NA

# ---- Extract EVI values at sensor locations ----
sensor_evi_silwood <- terra::extract(evi_silwood, sensor_locations)

# Create a data frame with grid and EVI values
sensor_evi_df <- data.frame(
  grid = sensor_locations$Grid,
  EVI_Silwood = sensor_evi_silwood$EVI
)

# writting sensor EVI data to CSV
write_csv(sensor_evi_df,
          file = "../results/sensor_evi_silwood.csv")


# Merge EVI values with sensor_locations using the grid column
sensor_locations <- sensor_locations %>%
  left_join(sensor_evi_df, by = "grid")

# sensor_locations now contains EVI values for Silwood only


names(s2_silwood_10m) <- "R"

# Transform sensor locations to match raster CRS
sensor_locations <- st_transform(sensor_locations, crs = crs(s2_silwood_10m))

# Plot raster
plot(evi_silwood, main = "Sensor Locations on Silwood Raster")

# Overlay sensor locations
plot(st_geometry(sensor_locations), add = TRUE, col = "red", pch = 19, cex = 1.2)
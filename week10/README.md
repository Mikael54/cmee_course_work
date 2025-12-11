# 2025 CMEE Coursework Repository

## Description

This repository contains coursework completed during the Data Science in Ecology and Evolution course at Imperial College London.

⚠️ **Note:** Due to file size constraints, satellite imagery (.tiff), shapefiles, and large spatial datasets are not included in this repository. Please contact mikael.minten25@imperial.ac.uk if you need the complete dataset to run this code.

## Repository Structure

This folder contains:
- `/code`: R scripts for integrative spatial and ecological analysis
- `/data`: Camera trap data, sensor locations, and Sentinel-2 imagery (large files in .gitignore)
- `/results`: Analysis outputs and statistical results
- `/sandbox`: Working space and reference papers

## Languages

This project uses the following languages:

- **R** - Version 4.0+

### System Requirements
- Unix/Linux environment or macOS
- R 4.0 or higher
- R packages: `sf`, `terra`, `raster`, `lme4`, `tidyverse`, `ggplot2`

## Scripts and Programs

### Quick Reference
- [**initial_analysis.R**](#initial_analysisr) - Exploratory data analysis of camera trap records
- [**evi_analysis.r**](#evi_analysisr) - Calculates Enhanced Vegetation Index from Sentinel-2 imagery
- [**glmer_stats_evi_muntjac.R**](#glmer_stats_evi_muntjacr) - Statistical modeling of muntjac presence with vegetation indices

---

### initial_analysis.R

**Purpose:** Performs initial data exploration and cleaning of camera trap species detection data. Aggregates records by species, site, and date.

**Usage:**
```R
Rscript initial_analysis.R
```

**Input:** 
- Camera trap CSV files from `../data/camera_trap/`
- Sensor site metadata

**Output:** 
- `species_by_date_station.csv` - Aggregated species records
- `mammals_data.csv` - Cleaned mammal detection data

### evi_analysis.r

**Purpose:** Extracts and calculates Enhanced Vegetation Index (EVI) from Sentinel-2 satellite imagery at sensor locations. Links remote sensing data with field monitoring sites.

**Usage:**
```R
Rscript evi_analysis.r
```

**Input:** 
- Sentinel-2 multispectral bands (B02, B04, B08) at 10m resolution
- Sensor site coordinates from `../data/sensor_sites/`

**Output:** 
- `sensor_evi_silwood.csv` - EVI values for each sensor location

### glmer_stats_evi_muntjac.R

**Purpose:** Builds generalized linear mixed-effects models (GLMER) to analyze relationships between muntjac deer presence and vegetation indices, controlling for spatial and temporal effects.

**Usage:**
```R
Rscript glmer_stats_evi_muntjac.R
```

**Input:** 
- `muntjac_records.csv` - Muntjac detection data
- `sensor_evi_silwood.csv` - Vegetation indices

**Output:** 
- Statistical model summaries
- Visualization plots (PDF)

**Dependencies:**
- `lme4` package for mixed-effects modeling

## Author
**Mikael Ridza Minten**  
Email: mikael.minten25@imperial.ac.uk  
Institution: Imperial College London

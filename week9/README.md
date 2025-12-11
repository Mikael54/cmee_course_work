# 2025 CMEE Coursework Repository

## Description

This repository contains coursework completed during the Data Science in Ecology and Evolution course at Imperial College London - Spatial Methods and Remote Sensing module.

⚠️ **Note:** Due to file size constraints, satellite imagery (.tiff), shapefiles, and large spatial datasets are not included in this repository. Please contact mikael.minten25@imperial.ac.uk if you need the complete dataset to run this code.

## Repository Structure

This folder contains:
- `/code`: R scripts for spatial analysis
- `/data`: Metadata and smaller spatial datasets (large files in .gitignore)
- `/eco_evo_data_science`: Course materials and example data
- `/results`: Analysis outputs
- `/sandbox`: Working space for spatial data processing

## Languages

This project uses the following languages:

- **R** - Version 4.0+

### System Requirements
- Unix/Linux environment or macOS
- R 4.0 or higher
- R spatial packages: `sf`, `terra`, `raster`, `ggplot2`, `tidyverse`

## Scripts and Programs

### Quick Reference
- [**spatial_methods.R**](#spatial_methodsr) - Comprehensive spatial analysis workflow including raster and vector operations

---

### spatial_methods.R

**Purpose:** Performs spatial data processing including loading and analyzing Sentinel-2 satellite imagery, calculating vegetation indices (NDVI, EVI), processing shapefiles, and creating spatial visualizations.

**Usage:**
```R
Rscript spatial_methods.R
```

**Input:** 
- Sentinel-2 multispectral imagery (10m, 20m, 60m resolution bands)
- Vector data (shapefiles, GeoPackages)
- Land cover classification data

**Output:** 
- Vegetation index rasters
- Spatial analysis plots
- Processed spatial datasets

**Note:** This script requires large satellite imagery files. Ensure data files are in `../data/sentinel_2/` directory structure.

## Author
**Mikael Ridza Minten**  
Email: mikael.minten25@imperial.ac.uk  
Institution: Imperial College London

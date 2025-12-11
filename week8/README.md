# 2025 CMEE Coursework Repository

## Description

This repository contains coursework completed during the Data Science in Ecology and Evolution course at Imperial College London - Bioacoustics and Camera Trap Analysis module.

⚠️ **Note:** Due to file size constraints, audio files (.wav) and camera trap images are not included in this repository. Please contact mikael.minten25@imperial.ac.uk if you need the complete dataset to run this code.

## Repository Structure

This folder contains:
- `/code`: R scripts for acoustic and camera trap analysis
- `/data`: Camera trap metadata tables
- `/results`: BirdNET analysis outputs
- `/sandbox`: Raw audio files and camera images (not tracked in git due to size)

## Languages

This project uses the following languages:

- **R** - Version 4.0+
- **Python** - Version 3.8+ (for BirdNET integration)

### System Requirements
- Unix/Linux environment or macOS
- R 4.0 or higher
- Python 3.8+ with BirdNET dependencies

## Scripts and Programs

### Quick Reference
- [**birdnet_analysis.R**](#birdnet_analysisr) - Processes audio files with BirdNET for bird species identification
- [**birdnet_post_processing.R**](#birdnet_post_processingr) - Cleans and filters BirdNET output data
- [**acoustic_indices.r**](#acoustic_indicesr) - Calculates acoustic diversity indices
- [**camera_trap.R**](#camera_trapr) - Analyzes camera trap species detection data
- [**visualization.R**](#visualizationr) - Creates plots and visualizations of species data

---

### birdnet_analysis.R

**Purpose:** Interfaces with BirdNET Python library to analyze audio recordings and identify bird species from acoustic data.

**Usage:**
```R
Rscript birdnet_analysis.R
```

### birdnet_post_processing.R

**Purpose:** Filters BirdNET results by confidence threshold and aggregates detections by site and time.

**Usage:**
```R
Rscript birdnet_post_processing.R
```

### acoustic_indices.r

**Purpose:** Computes acoustic complexity indices (ACI, ADI, etc.) to assess soundscape diversity.

**Usage:**
```R
Rscript acoustic_indices.r
```

### camera_trap.R

**Purpose:** Processes camera trap data tables to analyze species presence, activity patterns, and detection rates.

**Usage:**
```R
Rscript camera_trap.R
```

### visualization.R

**Purpose:** Generates visualizations of species detections across sites and time periods.

**Usage:**
```R
Rscript visualization.R
```

## Author
**Mikael Ridza Minten**  
Email: mikael.minten25@imperial.ac.uk  
Institution: Imperial College London

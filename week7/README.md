# 2025 CMEE Coursework Repository

## Description

This repository contains coursework completed during the HPC (High Performance Computing) course at Imperial College London.

⚠️ **Note:** Due to file size constraints, not all data files (.rda outputs) are included in this repository. Please contact mikael.minten25@imperial.ac.uk if you need the complete dataset to run this code.

## Repository Structure

This folder contains:
- `/code`: R scripts for HPC cluster simulations
- `/output_files`: Simulation results (not tracked in git due to size)

## Languages

This project uses the following languages:

- **R** - Version 4.0+
- **Bash** - For HPC job submission

### System Requirements
- HPC cluster access with R installed
- PBS/SLURM job scheduler

## Scripts and Programs

### Quick Reference
- [**abc123_HPC_2025_main.R**](#abc123_hpc_2025_mainr) - Main simulation coordinator script
- [**abc123_HPC_2025_demographic_cluster.R**](#abc123_hpc_2025_demographic_clusterr) - Demographic simulation for cluster
- [**abc123_HPC_2025_neutral_cluster.R**](#abc123_hpc_2025_neutral_clusterr) - Neutral model simulation for cluster
- [**running_hpc.sh**](#running_hpcsh) - Batch job submission script

---

### abc123_HPC_2025_main.R

**Purpose:** Coordinates and submits multiple simulation jobs to HPC cluster. Manages parameter sweeps for demographic and neutral models.

**Usage:**
```bash
Rscript abc123_HPC_2025_main.R
```

### abc123_HPC_2025_demographic_cluster.R

**Purpose:** Runs demographic population model simulations with varying adult size and spread parameters on HPC cluster.

**Usage:**
```bash
Rscript abc123_HPC_2025_demographic_cluster.R
```

### abc123_HPC_2025_neutral_cluster.R

**Purpose:** Runs neutral model simulations for comparison with demographic models on HPC cluster.

**Usage:**
```bash
Rscript abc123_HPC_2025_neutral_cluster.R
```

### running_hpc.sh

**Purpose:** Shell script for submitting R jobs to HPC scheduler with appropriate resource allocation.

**Usage:**
```bash
bash running_hpc.sh
```

## Author
**Mikael Ridza Minten**  
Email: mikael.minten25@imperial.ac.uk  
Institution: Imperial College London

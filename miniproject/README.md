# Microbial Growth Curve Analysis

**Author:** Mikael Minten  
**Date:** March 2026  
**Institution:** Imperial College London - MSc Computational Methods in Ecology and Evolution (CMEE)

---

## Description

This project presents statistical analysis of microbial growth curves, comparing the performance of multiple mechanistic and phenomenological growth models (Buchanan, Baranyi, and linear) and assessing the effect of temperature on growth parameters.

The repository contains both the analytical pipeline and the relevant LaTeX manuscript.

---

## Repository Structure

```
miniproject/
│
├── code/
│   ├── run_analysis.sh             # Master script to execute full analysis
│   ├── data_preparation.R          # Data cleaning and preprocessing
│   ├── model_fitting.R             # Growth model implementation and fitting
│   ├── citations.bib               # Bibliography file
│   └── latex.tex                   # LaTeX manuscript notes
│
├── data/
│   ├── logistic_growth_data.csv    # Raw microbial growth measurements
│   └── logistic_growth_meta_data.csv # Metadata for growth experiments
│
├── results/
│   ├── data_clean.csv              # [OUTPUT] Cleaned and processed dataset
│   ├── *.pdf                       # [OUTPUT] Various figures for the report 
│   └── report.pdf                  # [OUTPUT] Compiled manuscript
│
└── README.md                       # This file
```

---

## Files

### Code

- **[`data_preparation.R`](#data_preparationr)** — Data preprocessing and quality control  
- **[`model_fitting.R`](#model_fittingr)** — Model implementation, fitting, and evaluation  
- **[`run_analysis.sh`](#run_analysissh)** — Automated execution script

### Data

- **[`logistic_growth_data.csv`](#logistic_growth_datacsv)** — Input dataset  
- **[`logistic_growth_meta_data.csv`](#logistic_growth_meta_datacsv)** — Experimental metadata

### Results

- **[`data_clean.csv`](#data_cleancsv)** — [OUTPUT] Processed data  
- **[`sample_curves.pdf`](#sample_curvespdf)** — [OUTPUT] Sample growth curve fits
- **[`rmax_thermal_performance_plot.pdf`](#rmax_thermal_performance_plotpdf)** — [OUTPUT] Thermal performance plot
- **[`report.pdf`](#reportpdf)** — [OUTPUT] Compiled manuscript

---

## Detailed File Descriptions

### `data_preparation.R`
Performs data cleaning and preprocessing:
- **Input:** `data/logistic_growth_data.csv`
- **Processing:**
  - Removes incomplete growth curves (< 6 time points)
  - Filters non-monotonic growth patterns
  - Removes negative time and population values
  - Standardizes variable naming conventions
  - Assigns unique identifiers to experimental replicates
  - Log-transforms population values
- **Output:** `results/data_clean.csv`

### `model_fitting.R`
Implements growth model fitting pipeline:
- **Input:** `results/data_clean.csv`
- **Methods:**
  - Fits Buchanan (three-phase linear), Baranyi (dynamic lag-phase), and linear models
  - Uses `nls_multstart` for robust parameter estimation (3,000 start combinations, convergence threshold = 100)
  - Performs model selection via AICc and Akaike weights
  - Extracts thermal parameters (growth rate *r*) for Boltzmann-Arrhenius analysis
  - Fits mixed-effects models to account for medium and study effects
- **Outputs:**
  - Various PDF figures showing model fits and thermal responses
  - Statistical analysis results

### `run_analysis.sh`
Master bash script to execute the full analysis pipeline. Must be run from the `code/` directory:
- Cleans any leftover LaTeX auxiliary files from `results/`
- Runs `data_preparation.R`
- Runs `model_fitting.R`
- Copies `latex.tex` and `citations.bib` into `results/` and compiles the LaTeX report
- Provides progress feedback and error handling

### `logistic_growth_data.csv`
The dataset contains measurements of changes in microbial biomass or cell numbers over time. These data originate from laboratory experiments conducted by researchers in various locations around the world. The data include multiple bacterial species grown at various temperatures on different growth media.

### `logistic_growth_meta_data.csv`
Metadata file containing information about the experimental conditions and citations for each growth curve study.

### `latex.tex`
LaTeX manuscript source file containing:
- Introduction to microbial growth modelling
- Statistical methodology (model selection, thermal analysis)
- Results (convergence rates, model comparison, Arrhenius temperature dependence)
- Discussion of ecological and food safety implications

### `citations.bib`
BibTeX bibliography file containing all references cited in the manuscript.

---

## Instructions

### Installation

#### System Requirements

- **R** ≥ 4.0
- **LaTeX distribution** (for manuscript compilation)
  - **Linux (Ubuntu/Debian):** `sudo apt-get install texlive-full`
  - **macOS:** Install [MacTeX](https://www.tug.org/mactex/)
  - **Windows:** Install [MiKTeX](https://miktex.org/)
- **Git** (for cloning the repository)

#### 1. Clone the Repository

```bash
git clone https://github.com/Mikael54/cmee_course_work.git
cd cmee_course_work/miniproject/code
```

#### 2. Install Required R Packages

```bash
Rscript -e 'install.packages(c("ggplot2", "ggeffects", "tidyverse", "minpack.lm", "nls.multstart", "AICcmodavg", "zoo", "nlstools", "lme4", "lmerTest", "performance", "see", "patchwork"), repos="https://cran.r-project.org")'
```
---

### Running the Analysis

#### Automated Workflow (Recommended)

The entire analysis pipeline can be executed with a single command:

```bash
bash run_analysis.sh
```

This script will automatically:
1. Run `data_preparation.R` → generates `../results/data_clean.csv`
2. Run `model_fitting.R` → generates plots in `../results/`
3. Compile the LaTeX report → generates `../results/report.pdf`

---

### Output Files

All output files are generated in the `results/` directory:
- `data_clean.csv` — Cleaned dataset
- `rmax_thermal_performance_plot.pdf` — Plot showing the effect of temperature on r_max
- `sample_curves.pdf` — Three sample plot of the highest Akaike Weight growth curves
- `report.pdf` — Final compiled manuscript

---

## Input Data

The dataset contains measurements of changes in microbial biomass or cell numbers over time. These data originate from various laboratory experiments. The data include multiple bacterial species grown at various temperatures on different growth media.

---

## Acknowledgments

This work was completed as part of the **MSc Computational Methods in Ecology and Evolution (CMEE)** program at **Imperial College London**. The dataset was provided by the CMEE course.

---

## Contact

For questions or inquiries:  
**Mikael Minten** — [mikael.minten25@imperial.ac.uk]

---

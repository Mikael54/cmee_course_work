# Microbial Growth Curve Analysis

**Author:** Mikael Minten  
**Date:** 2024  
**Institution:** Imperial College London - MSc Computational Methods in Ecology and Evolution (CMEE)

---

## Description

This project presents statistical analysis of microbial growth curves, comparing the performance of multiple mechanistic and phenomenological growth models (Buchanan, Baranyi, and linear) across diverse experimental conditions.

The repository contains both the analytical pipeline and the LaTeX manuscript documenting the methodological approach, results, and ecological implications.

---

## Repository Structure

```
miniproject/
│
├── code/
│   ├── data_wrangling.R          # Data cleaning and preprocessing
│   ├── model_fitting.R            # Growth model implementation and fitting
│   └── [run_analysis.sh]          # [PLACEHOLDER] Master script to execute full 
│
├── data/
│   └── LogisticGrowthData.csv     # Raw microbial growth measurements
│   └── miniproject.tex            # [PLACEHOLDER] Manuscript source file
│
├── results/
│   ├── data_clean.csv             # [OUTPUT] Cleaned and processed dataset
│   ├── thermal_response_*.pdf     # [OUTPUT] Thermal performance curves
│   └── [miniproject.pdf]          # [OUTPUT] Compiled LaTeX manuscript
│
├── latex/
│   └── 
│
└── README.md                      # This file
```

---

## Files

### Code

- **[`data_wrangling.R`](#data_wranglingr)** — Data preprocessing and quality control  
- **[`model_fitting.R`](#model_fittingr)** — Model implementation, fitting, and evaluation  
- **[`run_analysis.sh`](#run_analysissh)** — [PLACEHOLDER] Automated execution script

### Data

- **[`LogisticGrowthData.csv`](#logisticgrowthdatacsv)** — Input dataset  

### Results

- **[`data_clean.csv`](#data_cleancsv)** — [OUTPUT] Processed data  

### Documentation

- **[`miniproject.tex`](#miniprojecttex)** — Manuscript source

---

## Detailed File Descriptions

### `data_wrangling.R`
Performs data cleaning and preprocessing:
- **Input:** `data/LogisticGrowthData.csv`
- **Processing:**
  - Removes incomplete growth curves (< 3 time points)
  - Filters non-monotonic growth patterns
  - Standardizes variable naming conventions
  - Assigns unique identifiers to experimental replicates
- **Output:** `results/data_clean.csv`

### `model_fitting.R`
Implements growth model fitting pipeline:
- **Input:** `results/data_clean.csv`
- **Methods:**
  - Fits Buchanan (three-phase linear), Baranyi (dynamic lag-phase), and linear models
  - Uses `nls_multstart` for robust parameter estimation (3000 iterations, convergence threshold = 100)
  - Performs model selection via AICc and Akaike weights
  - Extracts thermal parameters (growth rate *r*) for Boltzmann-Arrhenius analysis
  - Fits mixed-effects models to account for species, medium, and study effects
- **Outputs:**
  - PLACEHOLDER

### `run_analysis.sh`
**[PLACEHOLDER]** Master script to execute the full analysis:
```bash
# Will run:
# 1. data_wrangling.R
# 2. model_fitting.R
# 3. LaTeX compilation
```

### `LogisticGrowthData.csv`
The dataset contains measurements of changes in microbial biomass or cell numbers over time. These data originate from laboratory experiments conducted by researchers in various locations around the world.

### `miniproject.tex`
LaTeX manuscript documenting:
- Introduction to microbial growth modeling
- Statistical methodology (model selection, thermal analysis)
- Results (convergence rates, model comparison, activation energy estimates)
- Discussion of ecological implications

---

## Instructions

### Installation

#### Dependencies

**R packages:**
```r
install.packages(c(
  "ggplot2", "tidyverse", "minpack.lm", "nls.multstart",
  "AICcmodavg", "zoo", "nlstools", "lme4", "lmerTest", "performance"
))
```

**System requirements:**
- R ≥ 4.0
- LaTeX distribution (for manuscript compilation; e.g., TeX Live, MiKTeX)

#### Clone Repository
```bash
git clone https://github.com/your-username/cmee_course_work.git
cd cmee_course_work/miniproject
```

---

### Running the Analysis

**[PLACEHOLDER - Full automation pending]**

---
## Input Data

The dataset contains measurements of changes in microbial biomass or cell numbers over time. These data originate from laboratory experiments conducted by researchers in various locations around the world. The data include multiple bacterial species grown at various temperatures on different growth media.

---

## License

**[PLACEHOLDER]**  
This project will be released under an open-source license. See [LICENSE](https://en.wikipedia.org/wiki/Software_license) for details.

---

## Acknowledgments

This work was completed as part of the **MSc Computational Methods in Ecology and Evolution (CMEE)** program at **Imperial College London**. The dataset was provided by the CMEE course.

---

## Contact

For questions or collaboration inquiries:  
**Mikael Minten** — [mikael.minten25@imperial.ac.uk]

---

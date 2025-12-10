# 2025 CMEE Bootcamp Coursework Repository

## Description

This repository contains coursework completed during week 3 of 2025 CMEE Bootcamp at Imperial College London. 

## Repository Structure

This folder folder contains:
- `/code`: Scripts and programs developed during this week
- `/data`: Input data files used for exercises
- `/results`: Output files and analysis results, note that these are not uploaded and you will have to generate your own results using the code provided.

## Languages

This project uses the following languages:

- **R** - Version 4.0+

### System Requirements
- Unix/Linux environment or macOS
- R 4.0 or higher
- R packages: `tidyverse`, `ggplot2`, `reshape2`, `sqldf`
- LaTeX distribution with pdflatex (for document compilation)
- Evince PDF viewer (for viewing compiled documents)

## Scripts and Programs

### Quick Reference
- [**apply_1.R**](#apply_1r) - Matrix operations with `apply()` function
- [**apply_2.R**](#apply_2r) - Advanced `apply()` with custom functions
- [**basic_io.R**](#basic_ior) - File input/output operations
- [**boilerplate.R**](#boilerplater) - R function template
- [**break.R**](#breakr) - Loop termination with `break` statement
- [**browse.R**](#browser) - Debugging with `browser()` function
- [**compile_latex_florida.sh**](#compile_latex_floridash) - Compiles LaTeX document for Florida analysis
- [**control_flow.R**](#control_flowr) - If-else, for, and while loop structures
- [**data_wrang.R**](#data_wrangr) - Tidyverse data wrangling on Pound Hill dataset
- [**florida.R**](#floridar) - Permutation testing for temperature trends
- [**girko.R**](#girkor) - Visualizes Girko's circular law with eigenvalues
- [**my_bars.R**](#my_barsr) - Multi-layered bar chart with ggplot2
- [**next.R**](#nextr) - Skip loop iterations with `next` statement
- [**plot_lin.R**](#plot_linr) - Linear regression plot with residuals
- [**pp_regress.R**](#pp_regressr) - Predator-prey body mass regression analysis
- [**preallocate.R**](#preallocater) - Vector preallocation performance comparison
- [**r_conditionals.R**](#r_conditionalsr) - Conditional logic functions
- [**sample.R**](#sampler) - Simulation approaches benchmark (loops vs vectorized)
- [**sq_linr.R**](#sq_linrr) - SQLite database operations
- [**tree_heights.R**](#tree_heightsr) - Calculates tree heights from trigonometry
- [**try.r**](#tryr) - Error handling with `try()` function
- [**vectorize_1.R**](#vectorize_1r) - Vectorization performance comparison

---

### apply_1.R

**Purpose:** Demonstrates the use of the `apply()` function in R for performing operations on matrix rows and columns. Calculates means and variances across rows and columns of a random matrix.

**Usage:**
```R
Rscript apply_1.R
```

**Example:**
```bash
cd code
Rscript apply_1.R
```

### apply_2.R

**Purpose:** Illustrates advanced use of `apply()` with custom functions. Applies a conditional transformation function to matrix rows based on their sum.

**Usage:**
```R
Rscript apply_2.R
```

**Example:**
```bash
cd code
Rscript apply_2.R
```

### basic_io.R

**Purpose:** Demonstrates fundamental file input/output operations in R, including reading CSV files, writing data with various options (headers, row names, column names), and appending to files.

**Usage:**
```R
Rscript basic_io.R
```

**Input:** Requires `../data/trees.csv`.

**Output:** Creates `../results/my_data.csv`.

**Example:**
```bash
cd code
Rscript basic_io.R
```

### boilerplate.R

**Purpose:** Provides a template for R functions showing proper structure, argument handling, and type checking. Demonstrates function definition with multiple arguments and return values.

**Usage:**
```R
Rscript boilerplate.R
```

**Example:**
```bash
cd code
Rscript boilerplate.R
```

### break.R

**Purpose:** Demonstrates the use of the `break` statement to exit loops early. Shows a while loop that terminates when a specific condition is met.

**Usage:**
```R
Rscript break.R
```

**Example:**
```bash
cd code
Rscript break.R
```

### browse.R

**Purpose:** Illustrates the `browser()` function for debugging R code. Simulates exponential population growth and pauses execution at each iteration for inspection.

**Usage:**
```R
Rscript browse.R
```

**Example:**
```bash
cd code
Rscript browse.R
```

### compile_latex_florida.sh

**Purpose:** Bash script to compile a LaTeX document multiple times (ensuring all references are resolved), move the PDF to the results directory, and open it in Evince.

**Usage:**
```bash
bash compile_latex_florida.sh
```

**Input:** Requires `../data/florida_text.tex`.

**Output:** Creates `../results/florida_text.pdf`.

**Dependencies:**
- pdflatex
- evince

**Example:**
```bash
cd code
bash compile_latex_florida.sh
```

### control_flow.R

**Purpose:** Demonstrates fundamental control flow structures in R including if-else statements, for loops over numeric ranges and character vectors, and while loops.

**Usage:**
```R
Rscript control_flow.R
```

**Example:**
```bash
cd code
Rscript control_flow.R
```

### data_wrang.R

**Purpose:** Comprehensive data wrangling script demonstrating tidyverse operations. Transforms the Pound Hill ecological dataset from wide to long format, converts data types, and performs exploratory data analysis using dplyr functions.

**Usage:**
```R
Rscript data_wrang.R
```

**Input:** Requires `../data/pound_hill_data.csv` and `../data/pound_hill_meta_data.csv`.

**Dependencies:**
- tidyverse
- reshape2

**Example:**
```bash
cd code
Rscript data_wrang.R
```

### florida.R

**Purpose:** Performs permutation testing to assess statistical significance of temperature trends in Key West, Florida over the 20th century. Generates a publication-quality plot showing temperature change over time with linear regression.

**Usage:**
```R
Rscript florida.R
```

**Input:** Requires `../data/key_west_annual_mean_temperature.RData`.

**Output:** Creates `../results/temperature_plot.pdf`.

**Dependencies:**
- tidyverse

**Example:**
```bash
cd code
Rscript florida.R
```

### girko.R

**Purpose:** Simulates and visualizes Girko's circular law by plotting eigenvalues of a random matrix. Generates eigenvalues from a large random matrix and overlays them on a circular boundary predicted by the theorem.

**Usage:**
```R
Rscript girko.R
```

**Output:** Creates `../results/girko.pdf`.

**Dependencies:**
- tidyverse

**Example:**
```bash
cd code
Rscript girko.R
```

### my_bars.R

**Purpose:** Creates a multi-layered bar chart visualization using ggplot2. Demonstrates geom_linerange for creating custom bar plots with multiple data series and annotations.

**Usage:**
```R
Rscript my_bars.R
```

**Input:** Requires `../data/results.txt`.

**Output:** Creates `../results/my_bars.pdf`.

**Dependencies:**
- ggplot2

**Example:**
```bash
cd code
Rscript my_bars.R
```

### next.R

**Purpose:** Demonstrates the `next` statement to skip specific iterations in a loop. Prints only odd numbers by skipping even numbers.

**Usage:**
```R
Rscript next.R
```

**Example:**
```bash
cd code
Rscript next.R
```

### plot_lin.R

**Purpose:** Creates a linear regression plot with color-coded residuals and mathematical expressions. Demonstrates advanced ggplot2 features including custom axis labels with mathematical notation.

**Usage:**
```R
Rscript plot_lin.R
```

**Output:** Creates `../results/my_lin_reg.pdf`.

**Dependencies:**
- ggplot2

**Example:**
```bash
cd code
Rscript plot_lin.R
```

### pp_regress.R

**Purpose:** Analyzes predator-prey body mass relationships from ecological data. Performs log-log regression by feeding interaction type and life stage, produces faceted plots, and exports statistical results.

**Usage:**
```R
Rscript pp_regress.R
```

**Input:** Requires `../data/ecol_archives_e089_51_d1.csv`.

**Output:** Creates `../results/reggression.pdf` and `../results/reggression_results.csv`.

**Dependencies:**
- tidyverse

**Example:**
```bash
cd code
Rscript pp_regress.R
```

### preallocate.R

**Purpose:** Demonstrates the performance benefits of preallocating vectors in R. Compares execution time between growing vectors dynamically versus preallocating memory.

**Usage:**
```R
Rscript preallocate.R
```

**Example:**
```bash
cd code
Rscript preallocate.R
```

### r_conditionals.R

**Purpose:** Collection of functions demonstrating conditional logic in R. Includes functions to check if numbers are even, powers of 2, or prime numbers.

**Usage:**
```R
Rscript r_conditionals.R
```

**Example:**
```bash
cd code
Rscript r_conditionals.R
```

### sample.R

**Purpose:** Comprehensive comparison of different approaches to running repeated simulations in R. Benchmarks loops with/without preallocation versus vectorized functions (lapply, sapply).

**Usage:**
```R
Rscript sample.R
```

**Example:**
```bash
cd code
Rscript sample.R
```

### sq_linr.R

**Purpose:** Demonstrates database operations in R using SQLite. Creates tables, inserts data, performs queries, and imports CSV files into a database.

**Usage:**
```R
Rscript sq_linr.R
```

**Input:** Requires `../data/resource.csv`.

**Output:** Creates `Test.sqlite` database file.

**Dependencies:**
- sqldf

**Example:**
```bash
cd code
Rscript sq_linr.R
```

### tree_heights.R

**Purpose:** Calculates tree heights from distance and angle measurements using trigonometry. Reads tree data, applies the height calculation formula, and exports results.

**Usage:**
```R
Rscript tree_heights.R
```

**Input:** Requires `../data/trees.csv`.

**Output:** Creates `../results/tree_hts.csv`.

**Dependencies:**
- tidyverse

**Example:**
```bash
cd code
Rscript tree_heights.R
```

### try.r

**Purpose:** Demonstrates error handling in R using the `try()` function. Shows how to continue execution when errors occur in loops by catching and handling exceptions gracefully.

**Usage:**
```R
Rscript try.r
```

**Example:**
```bash
cd code
Rscript try.r
```

### vectorize_1.R

**Purpose:** Demonstrates the performance advantages of vectorization in R. Compares nested loop summation versus built-in vectorized functions on large matrices.

**Usage:**
```R
Rscript vectorize_1.R
```

**Example:**
```bash
cd code
Rscript vectorize_1.R
```

## Author
**Mikael Ridza Minten**  
Email: mikael.minten25@imperial.ac.uk  
Institution: Imperial College London  
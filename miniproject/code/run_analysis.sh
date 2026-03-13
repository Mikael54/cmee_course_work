#!/bin/bash

# Microbial Growth Curve Analysis Pipeline
# Author: Mikael Minten
# Description: Automated workflow for data preparation, model fitting, and report compilation

set -e  # Exit on error

echo "================================================"
echo "Starting Microbial Growth Curve Analysis"
echo "================================================"
echo ""

RESULTS_DIR="../results"

# Clean up any leftover LaTeX auxiliary files from previous runs (compile in code/)
rm -f latex.aux latex.log latex.out latex.bbl latex.blg latex.toc latex.lof latex.lot

# Step 1: Data Preparation
echo "[1/3] Running data preparation..."
echo "----------------------------------------------"
Rscript data_preparation.R
if [ $? -eq 0 ]; then
    echo "Data preparation completed successfully"
    echo ""
else
    echo "Error in data preparation"
    exit 1
fi

# Step 2: Model Fitting
echo "[2/3] Running model fitting and analysis..."
echo "----------------------------------------------"
Rscript model_fitting.R
if [ $? -eq 0 ]; then
    echo "Model fitting completed successfully"
    echo ""
else
    echo "Error in model fitting"
    exit 1
fi

# Step 3: Compile LaTeX Report
echo "[3/3] Compiling LaTeX report..."
pdflatex latex.tex
bibtex latex
pdflatex latex.tex
pdflatex latex.tex
mv latex.pdf "$RESULTS_DIR/report.pdf"
rm -f latex.aux latex.log latex.bbl latex.blg latex.out latex.toc latex.lof latex.lot

echo "================================================"

echo "Analysis Complete!"
echo "================================================"
echo "  - results/report.pdf (final report)"
echo ""
echo "================================================"
echo "Analysis Complete!"
echo "================================================"
echo ""
echo "Output files:"
echo "  - results/data_clean.csv (cleaned data)"
echo "  - results/*.pdf (figures and plots)"
if [ -f "$RESULTS_DIR/report.pdf" ]; then
    echo "  - results/report.pdf (final report)"
fi
echo ""






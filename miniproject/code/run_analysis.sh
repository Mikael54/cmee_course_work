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

# Clean up any leftover LaTeX auxiliary and source files from previous runs
rm -f "$RESULTS_DIR"/*.aux "$RESULTS_DIR"/*.log "$RESULTS_DIR"/*.out \
      "$RESULTS_DIR"/*.bbl "$RESULTS_DIR"/*.blg "$RESULTS_DIR"/*.toc \
      "$RESULTS_DIR"/*.lof "$RESULTS_DIR"/*.lot \
      "$RESULTS_DIR"/report.tex "$RESULTS_DIR"/citations.bib

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
echo "----------------------------------------------"

# Copy latex.tex and citations.bib into results/ for compilation
if [ ! -f "latex.tex" ]; then
    echo "Warning: latex.tex not found in code directory"
    echo "Skipping LaTeX compilation"
else
    cp "latex.tex" "$RESULTS_DIR/report.tex"

    if [ -f "citations.bib" ]; then
        cp "citations.bib" "$RESULTS_DIR/citations.bib"
    fi

    cd "$RESULTS_DIR"

    # Run pdflatex twice for proper cross-references
    pdflatex -interaction=nonstopmode report.tex > /dev/null 2>&1

    # Run bibtex if citations.bib was copied
    if [ -f "citations.bib" ]; then
        bibtex report > /dev/null 2>&1
        pdflatex -interaction=nonstopmode report.tex > /dev/null 2>&1
    fi

    # Final compilation
    pdflatex -interaction=nonstopmode report.tex > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "LaTeX compilation completed successfully"
        echo "Report generated: results/report.pdf"

        # Clean up all auxiliary and copied source files
        rm -f *.aux *.log *.out *.bbl *.blg *.toc *.lof *.lot report.tex citations.bib
    else
        echo "Error in LaTeX compilation"
        exit 1
    fi

    cd - > /dev/null
fi

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

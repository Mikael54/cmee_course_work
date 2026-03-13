#!/bin/bash

# Microbial Growth Curve Analysis Pipeline
# Author: Mikael Minten
# Description: Automated workflow for data preparation, model fitting, and report compilation

set -e  # Exit on error

echo "================================================"
echo "Starting Microbial Growth Curve Analysis"
echo "================================================"
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/code"

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
cd ../results

# Check if report.tex exists
if [ ! -f "report.tex" ]; then
    echo "Warning: report.tex not found in results directory"
    echo "Skipping LaTeX compilation"
else
    # Run pdflatex twice for proper cross-references
    pdflatex -interaction=nonstopmode report.tex > /dev/null 2>&1
    
    # Check if bibtex is needed (if citation.bib exists)
    if [ -f "../code/citation.bib" ]; then
        bibtex report > /dev/null 2>&1
        pdflatex -interaction=nonstopmode report.tex > /dev/null 2>&1
    fi
    
    # Final compilation
    pdflatex -interaction=nonstopmode report.tex > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "LaTeX compilation completed successfully"
        echo "Report generated: ../results/report.pdf"
        
        # Clean up auxiliary files
        rm -f *.aux *.log *.out *.bbl *.blg *.toc *.lof *.lot
    else
        echo "Error in LaTeX compilation"
        exit 1
    fi
fi

cd "$SCRIPT_DIR"

echo ""
echo "================================================"
echo "Analysis Complete!"
echo "================================================"
echo ""
echo "Output files:"
echo "  - results/data_clean.csv (cleaned data)"
echo "  - results/*.pdf (figures and plots)"
if [ -f "results/report.pdf" ]; then
    echo "  - results/report.pdf (final report)"
fi
echo ""

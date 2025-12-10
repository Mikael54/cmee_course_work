#!/bin/bash
# Author: Mikael Minten mikael.minten25@imprial.ac.uk
# Script: compile_latex.sh
# Desc: Compiles a latex file from a text file.
# Argument: The text file
# Date: Oct 2025

# Check if required packages are installed
if ! command -v pdflatex &> /dev/null; then
    echo "Error: pdflatex is not installed. Please install a LaTeX distribution (e.g., texlive)."
    exit 1
fi

if ! command -v bibtex &> /dev/null; then
    echo "Error: bibtex is not installed. Please install a LaTeX distribution (e.g., texlive)."
    exit 1
fi

if ! command -v evince &> /dev/null; then
    echo "Error: evince is not installed. Please install evince PDF viewer."
    exit 1
fi

# Check if argument provided
if [ -z "$1" ]; then
    echo "Error: No filename provided"
    exit 1
fi

# Remove .tex extension if present
filename=$(basename "$1" .tex)

# check if file exist
if [ ! -f "$filename.tex" ]; then
    echo "Error: $filename.tex not found"
    exit 1
fi

# Compile in current directory but move PDF to results
pdflatex $filename.tex
bibtex $filename
pdflatex $filename.tex
pdflatex $filename.tex

# Move PDF to results directory
mv $filename.pdf ../results/

# Open PDF from results directory
evince ../results/$filename.pdf &

## Cleanup
rm *.aux
rm *.log
rm *.bbl
rm *.blg
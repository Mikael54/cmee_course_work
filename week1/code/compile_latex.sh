#!/bin/bash

# Remove .tex extension if present
filename=$(basename "$1" .tex)

# Compile in current directory but move PDF to results
pdflatex $filename.tex
bibtex $filename.bib
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
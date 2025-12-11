#!/bin/bash


# Compile in current directory but move PDF to results
pdflatex florida_text.tex
pdflatex florida_text.tex
pdflatex florida_text.tex

# Move PDF to results directory
mv florida_text.pdf ../results/

# Open PDF from results directory
evince ../results/florida_text.pdf &

## Cleanup
rm -f florida_text.{aux,log,bbl,blg}
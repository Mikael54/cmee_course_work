#!/bin/bash
# Author: Mikael Minten mikael.minten25@imprial.ac.uk
# Script: tiff to png 
# Description: Tiff to png coversion script
# Argument: 1 -> Directory containing .tif files
# Date: Oct 2025

# Check if ImageMagick in installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it first."
    exit 1
fi

# Check if a directory is provided
if [ $# -eq 0 ]; then
    echo "Please provide a directory"
    exit 1
fi

# Check if there are tif files in the directory
if ! ls "$1"/*.tif 1> /dev/null 2>&1; then
    echo "Please provide a directory with .tif files"
    exit 1
fi

# Converting tif files to png and putting output in the results folder
for f in "$1"/*.tif; 
    do  
        echo "Converting $f"; 
        convert "$f"  "../results/$(basename "$f" .tif).png"; 
    done
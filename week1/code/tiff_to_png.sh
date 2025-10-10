#!/bin/bash
# Author: Mikael Minten mikael.minten25@imprial.ac.uk
# Script: tiff to png
# Desc: Tiff to png coversion script
# Argument: 1 -> Directory containing .tif files
# Saves the output as a .png file in the results directory
# Date: Oct 2025

if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it first."
    exit 1
fi


if [ $# -eq 0 ]; then
    echo "Please provide a directory"
    exit 1
fi


if ! ls "$1"/*.tif 1> /dev/null 2>&1; then
    echo "Please provide a directory with .tif files"
    exit 1
fi


for f in "$1"/*.tif; 
    do  
        echo "Converting $f"; 
        convert "$f"  "../results/$(basename "$f" .tif).png"; 
    done
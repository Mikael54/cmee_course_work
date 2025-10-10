#!/bin/bash

if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it first."
    exit 1
fi


if [ $# -eq 0 ]; then
    echo "Please provide a directory"
    exit 1
fi


if ! ls "$1"/*.tif 1> /dev/null 2>&1; then
    echo "No .tif file present"
    exit 1
fi


for f in "$1"/*.tif; 
    do  
        echo "Converting $f"; 
        convert "$f"  "../results/$(basename "$f" .tif).png"; 
    done
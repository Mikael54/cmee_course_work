#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please provide a file"
    exit 1
fi

# Check if file ends with .tiff
if [[ "$1" != *.tiff ]]; then
    echo "Error: File must have .tiff extension"
    exit 1
fi

for f in *.tif;
do
    echo "Converting $f";
    convert "$f" "../results/$(basename "$f" .tif).png";
done

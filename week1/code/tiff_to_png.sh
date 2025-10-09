#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please provide a directory"
    exit 1
fi


if ! ls "$1"/*.tif 1> /dev/null 2>&1; then
    echo "No .tif file present in the directory"
    exit 1
fi



for f in *.tif; 
    do  
        echo "Converting $f"; 
        convert "$f"  "$(basename "$f" .tif).png"; 
    done
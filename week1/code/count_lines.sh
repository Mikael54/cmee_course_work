#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please provide a file"
    exit 1
fi


NumLine=`wc -l < $1`
echo "the file $1 has $NumLine lines"
echo
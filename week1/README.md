# 2025 CMEE Bootcamp Coursework Repository

## Description

This repository contains coursework completed during week 1 of 2025 CMEE Bootcamp at Imperial College London. 

## Repository Structure

This folder folder contains:
- `/code`: Scripts and programs developed during this week
- `/data`: Input data files used for exercises
- `/results`: Output files and analysis results, note that these are not uploaded and you will have to generate your own results using the code provided.

## Languages

This project uses the following languages:

- **Bash** (Unix shell scripting) - Version 4.0+

### System Requirements
- Unix/Linux environment or macOS
- ImageMagick (for image conversion tasks)
- LaTeX distribution with pdflatex and bibtex (for document compilation)
- Evince PDF viewer (for viewing compiled LaTeX documents)

## Scripts and Programs

### Quick Reference
- [**boilerplate.sh**](#boilerplatesh) - Basic shell script template with header formatting
- [**concatenate_two_files.sh**](#concatenate_two_filessh) - Combines two files into one output file
- [**count_lines.sh**](#count_linessh) - Counts lines in a file
- [**csv_to_space.sh**](#csv_to_spacesh) - Converts CSV to space-separated format
- [**tab_to_csv.sh**](#tab_to_csvsh) - Converts tab-delimited to CSV format
- [**tiff_to_png.sh**](#tiff_to_pngsh) - Batch converts TIFF images to PNG
- [**variables.sh**](#variablessh) - Demonstrates variable usage and command-line arguments
- [**my_example_script.sh**](#my_example_scriptsh) - Simple greeting script
- [**compile_latex.sh**](#compile_latexsh) - Compiles LaTeX documents with bibliography

---

### boilerplate.sh

**Purpose:** Demonstrates the basic structure of a shell script with standard header formatting and a simple echo command.

**Usage:**
```bash
bash boilerplate.sh
```

**Example:**
```bash
cd code
bash boilerplate.sh
```

### concatenate_two_files.sh

**Purpose:** Combines the contents of two input files and writes the result to a new file in the results directory.

**Usage:**
```bash
bash concatenate_two_files.sh <file1> <file2> <output_file>
```

**Arguments:**
- `file1`: Path to the first input file
- `file2`: Path to the second input file
- `output_file`: Name of the output file (saved in ../results/)

**Example:**
```bash
cd code
bash concatenate_two_files.sh ../data/file1.txt ../data/file2.txt combined.txt
```

### count_lines.sh

**Purpose:** Counts and displays the number of lines in a specified file.

**Usage:**
```bash
bash count_lines.sh <input_file>
```

**Arguments:**
- `input_file`: Path to the file to analyze

**Example:**
```bash
cd code
bash count_lines.sh ../data/spawannxs.txt
```

### csv_to_space.sh

**Purpose:** Converts comma-separated values (CSV) files to space-separated format. The output is saved as a .txt file in the results directory.

**Usage:**
```bash
bash csv_to_space.sh <csv_file>
```

**Arguments:**
- `csv_file`: Path to the CSV file to convert

**Example:**
```bash
cd code
bash csv_to_space.sh ../data/temperatures/1800.csv
```

### tab_to_csv.sh

**Purpose:** Converts tab-delimited files to comma-separated values (CSV) format. The output is saved in the results directory.

**Usage:**
```bash
bash tab_to_csv.sh <tab_delimited_file>
```

**Arguments:**
- `tab_delimited_file`: Path to the tab-delimited file

**Example:**
```bash
cd code
bash tab_to_csv.sh ../data/spawannxs.txt
```

### tiff_to_png.sh

**Purpose:** Batch converts all TIFF (.tif) files in a specified directory to PNG format using ImageMagick. Converted files are saved in the results directory.

**Usage:**
```bash
bash tiff_to_png.sh <directory>
```

**Arguments:**
- `directory`: Path to the directory containing .tif files

**Dependencies:**
- ImageMagick (`convert` command)

**Example:**
```bash
cd code
bash tiff_to_png.sh ../sandbox/
```

### variables.sh

**Purpose:** Demonstrates variable usage in shell scripts, including command-line arguments, user input, and arithmetic operations.

**Usage:**
```bash
bash variables.sh [arg1] [arg2]
```

**Arguments:**
- `arg1`: (Optional) First demonstration argument
- `arg2`: (Optional) Second demonstration argument

**Example:**
```bash
cd code
bash variables.sh hello world
```

### my_example_script.sh

**Purpose:** A simple demonstration script that prints a greeting message to the current user.

**Usage:**
```bash
bash my_example_script.sh
```

**Example:**
```bash
cd code
bash my_example_script.sh
```

### compile_latex.sh

**Purpose:** Compiles a LaTeX document with bibliography support. Runs pdflatex and bibtex in the correct sequence, moves the resulting PDF to the results directory, and opens it in Evince. Automatically cleans up auxiliary files.

**Usage:**
```bash
bash compile_latex.sh <tex_file>
```

**Arguments:**
- `tex_file`: Name of the .tex file (with or without extension)

**Dependencies:**
- pdflatex
- bibtex
- evince

**Example:**
```bash
cd code
bash compile_latex.sh first_example.tex
```

## Author
**Mikael Ridza Minten**  
Email: mikael.minten25@imperial.ac.uk  
Institution: Imperial College London  
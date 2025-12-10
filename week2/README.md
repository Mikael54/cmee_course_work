# 2025 CMEE Bootcamp Coursework Repository

## Description

This repository contains coursework completed during week 2 of 2025 CMEE Bootcamp at Imperial College London. 

## Repository Structure

This folder folder contains:
- `/code`: Scripts and programs developed during this week
- `/data`: Input data files used for exercises
- `/results`: Output files and analysis results, note that these are not uploaded and you will have to generate your own results using the code provided.

## Languages

This project uses the following languages:

- **Python**  - Version 3.0+

### System Requirements
- Unix/Linux environment or macOS
- Python 3.0 or higher
- Python standard library modules: `sys`, `csv`, `pickle`, `doctest`, `difflib`

## Scripts and Programs

### Quick Reference
- [**align_seqs.py**](#align_seqspy) - Finds optimal DNA sequence alignment with scoring
- [**basic_csv.py**](#basic_csvpy) - Reads and writes CSV files
- [**basic_io1.py**](#basic_io1py) - Basic file reading operations
- [**basic_io2.py**](#basic_io2py) - Basic file writing operations
- [**basic_io3.py**](#basic_io3py) - Object serialization with pickle
- [**boilerplate.py**](#boilerplatepy) - Python script template
- [**cf_exercises_1.py**](#cf_exercises_1py) - Control flow exercises (sqrt, factorial, sorting)
- [**cf_exercises_2.py**](#cf_exercises_2py) - Loop and conditional demonstrations
- [**control_flow.py**](#control_flowpy) - Control flow examples (even/odd, divisors, primes)
- [**debugme.py**](#debugmepy) - Error handling with try-except blocks
- [**dictionary.py**](#dictionarypy) - Dictionary creation using loops and comprehensions
- [**lc1.py**](#lc1py) - List comprehensions for bird data extraction
- [**lc2.py**](#lc2py) - List comprehensions for rainfall filtering
- [**loops.py**](#loopspy) - Fundamental loop constructs
- [**my_example_script.py**](#my_example_scriptpy) - Simple function demonstration
- [**oaks.py**](#oakspy) - Filters oak species from taxa list
- [**oaks_debugme.py**](#oaks_debugmepy) - Oak filtering with fuzzy matching and doctests
- [**scope.py**](#scopepy) - Variable scope demonstration
- [**sysargv.py**](#sysargvpy) - Command-line argument handling
- [**test_control_flow.py**](#test_control_flowpy) - Doctest module demonstration
- [**tuple.py**](#tuplepy) - Tuple unpacking demonstration
- [**using_name.py**](#using_namepy) - Explains `__name__` variable behavior

---

### align_seqs.py

**Purpose:** Finds the optimal alignment between two DNA sequences by calculating match scores at different starting positions. Reads sequences from a CSV file and outputs the best alignment to a text file.

**Usage:**
```bash
python3 align_seqs.py
```

**Input:** Requires `../data/align_seq_sample.csv` containing two DNA sequences.

**Output:** Creates `../results/aligned_seq.txt` with the best alignment and score.

**Example:**
```bash
cd code
python3 align_seqs.py
```

### basic_csv.py

**Purpose:** Demonstrates reading and writing CSV files in Python. Reads species data from a CSV file and extracts specific columns to a new CSV file.

**Usage:**
```bash
python3 basic_csv.py
```

**Input:** Requires `../data/test_csv.csv` containing species data.

**Output:** Creates `../results/body_mass.csv` with species names and body mass values.

**Example:**
```bash
cd code
python3 basic_csv.py
```

### basic_io1.py

**Purpose:** Demonstrates basic file reading operations in Python, including reading line-by-line and skipping blank lines.

**Usage:**
```bash
python3 basic_io1.py
```

**Input:** Requires `../data/test.txt`.

**Example:**
```bash
cd code
python3 basic_io1.py
```

### basic_io2.py

**Purpose:** Demonstrates writing data to a file by saving a sequence of numbers (0-99) to a text file.

**Usage:**
```bash
python3 basic_io2.py
```

**Output:** Creates `../results/testout.txt` containing numbers 0-99.

**Example:**
```bash
cd code
python3 basic_io2.py
```

### basic_io3.py

**Purpose:** Demonstrates Python object serialization using the pickle module. Shows how to save and load complex Python objects (dictionaries) to/from binary files.

**Usage:**
```bash
python3 basic_io3.py
```

**Output:** Creates and reads `../data/testp.p` (binary pickle file).

**Example:**
```bash
cd code
python3 basic_io3.py
```

### boilerplate.py

**Purpose:** Provides a standard template for Python scripts, demonstrating proper structure including docstrings, metadata, imports, and the main function pattern.

**Usage:**
```bash
python3 boilerplate.py
```

**Example:**
```bash
cd code
python3 boilerplate.py
```

### cf_exercises_1.py

**Purpose:** Collection of functions demonstrating control flow concepts including conditionals, iteration, and recursion. Includes functions for square roots, comparison, sorting, and factorial calculations using different methods.

**Usage:**
```bash
python3 cf_exercises_1.py
```

**Example:**
```bash
cd code
python3 cf_exercises_1.py
```

### cf_exercises_2.py

**Purpose:** Demonstrates various loop constructs and conditional statements through "hello" printing functions with different iteration patterns and conditions.

**Usage:**
```bash
python3 cf_exercises_2.py
```

**Example:**
```bash
cd code
python3 cf_exercises_2.py
```

### control_flow.py

**Purpose:** Provides example functions illustrating control flow statements including if-elif-else chains, for loops, and function returns. Includes functions to check even/odd numbers, find divisors, and identify prime numbers.

**Usage:**
```bash
python3 control_flow.py
```

**Example:**
```bash
cd code
python3 control_flow.py
```

### debugme.py

**Purpose:** Demonstrates error handling in Python using try-except blocks. Shows how to catch and handle ZeroDivisionError and other exceptions gracefully.

**Usage:**
```bash
python3 debugme.py
```

**Example:**
```bash
cd code
python3 debugme.py
```

### dictionary.py

**Purpose:** Creates a dictionary mapping taxonomic orders to sets of species using both conventional loops and set comprehensions. Demonstrates two approaches to the same data organization task.

**Usage:**
```bash
python3 dictionary.py
```

**Example:**
```bash
cd code
python3 dictionary.py
```

### lc1.py

**Purpose:** Extracts and organizes bird data (Latin names, common names, and body masses) using both list comprehensions and conventional loops, demonstrating the equivalence of both approaches.

**Usage:**
```bash
python3 lc1.py
```

**Example:**
```bash
cd code
python3 lc1.py
```

### lc2.py

**Purpose:** Filters 1910 UK rainfall data by threshold values using both list comprehensions and loops. Identifies months with high rainfall (>100mm) and low rainfall (<50mm).

**Usage:**
```bash
python3 lc2.py
```

**Example:**
```bash
cd code
python3 lc2.py
```

### loops.py

**Purpose:** Demonstrates fundamental loop constructs in Python including for loops with ranges, iteration over lists, accumulators, and while loops.

**Usage:**
```bash
python3 loops.py
```

**Example:**
```bash
cd code
python3 loops.py
```

### my_example_script.py

**Purpose:** Simple demonstration script showing function definition and basic arithmetic operations (squaring a number).

**Usage:**
```bash
python3 my_example_script.py
```

**Example:**
```bash
cd code
python3 my_example_script.py
```

### oaks.py

**Purpose:** Filters oak species (genus Quercus) from a list of tree taxa using both loop-based and list comprehension approaches. Demonstrates string methods and set operations.

**Usage:**
```bash
python3 oaks.py
```

**Example:**
```bash
cd code
python3 oaks.py
```

### oaks_debugme.py

**Purpose:** Identifies oak species from a CSV file with robust error handling and fuzzy string matching to account for typos in genus names. Uses doctests for verification and outputs oak species to a new CSV file.

**Usage:**
```bash
python3 oaks_debugme.py
```

**Input:** Requires `../data/test_oak_data.csv` containing species data.

**Output:** Creates `../results/just_oaks_data.csv` with filtered oak species.

**Example:**
```bash
cd code
python3 oaks_debugme.py
```

### scope.py

**Purpose:** Illustrates the concept of variable scope in Python, demonstrating the difference between global and local variables and how they behave within and outside function definitions.

**Usage:**
```bash
python3 scope.py
```

**Example:**
```bash
cd code
python3 scope.py
```

### sysargv.py

**Purpose:** Demonstrates how to access command-line arguments in Python using the sys.argv list. Shows script name, argument count, and argument values.

**Usage:**
```bash
python3 sysargv.py [arg1] [arg2] ...
```

**Arguments:**
- Optional command-line arguments for demonstration

**Example:**
```bash
cd code
python3 sysargv.py hello world 123
```

### test_control_flow.py

**Purpose:** Demonstrates the doctest module for embedded testing in Python. Tests the even_or_odd function with various inputs including negative numbers.

**Usage:**
```bash
python3 test_control_flow.py
```

**Example:**
```bash
cd code
python3 test_control_flow.py
```

### tuple.py

**Purpose:** Demonstrates tuple unpacking in Python by iterating through bird data and extracting multiple variables simultaneously.

**Usage:**
```bash
python3 tuple.py
```

**Example:**
```bash
cd code
python3 tuple.py
```

### using_name.py

**Purpose:** Explains the `__name__` variable in Python and how it differs when a script is run directly versus imported as a module.

**Usage:**
```bash
python3 using_name.py
```

**Example:**
```bash
cd code
python3 using_name.py
```

## Author
**Mikael Ridza Minten**  
Email: mikael.minten25@imperial.ac.uk  
Institution: Imperial College London  
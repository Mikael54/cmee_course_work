# 2025 CMEE Bootcamp Coursework Repository

## Description

This repository contains coursework completed during week 4 of 2025 CMEE Bootcamp at Imperial College London. 

## Repository Structure

This folder contains:
- `/code`: Scripts and programs developed during this week
- `/data`: Input data files used for exercises
- `/results`: Output files and analysis results, note that these are not uploaded and you will have to generate your own results using the code provided.

## Languages

This project uses the following languages:

- **Python** - Version 3.0+

### System Requirements
- Unix/Linux environment or macOS
- Python 3.0 or higher
- Python standard library modules: `timeit`

## Scripts and Programs

### profile_me.py

**Purpose:** Demonstrates basic Python functions for performance profiling. Contains two functions (list squaring and string joining) implemented using traditional loops, designed to be profiled to identify performance bottlenecks.

**Usage:**
```bash
python3 profile_me.py
```

**Profiling Usage:**
```bash
python3 -m cProfile profile_me.py
```

**Example:**
```bash
cd code
python3 -m cProfile profile_me.py
```

### profile_me_2.py

**Purpose:** Optimized version of `profile_me.py` implementing the same functionality using more efficient Python constructs. Uses list comprehension for squaring and improved string concatenation for performance comparison.

**Usage:**
```bash
python3 profile_me_2.py
```

**Profiling Usage:**
```bash
python3 -m cProfile profile_me_2.py
```

**Example:**
```bash
cd code
python3 -m cProfile profile_me_2.py
```

### timeit_me.py

**Purpose:** Benchmarking script that compares the performance of different implementation approaches. Imports functions from both `profile_me.py` and `profile_me_2.py` to measure execution time differences between loops and list comprehensions, and between different string joining methods.

**Usage:**
```bash
python3 timeit_me.py
```

**Example:**
```bash
cd code
python3 timeit_me.py
```

**Note:** This script demonstrates how to use the `timeit` module for precise performance measurements of small code snippets.

## Author
**Mikael Ridza Minten**  
Email: mikael.minten25@imperial.ac.uk  
Institution: Imperial College London

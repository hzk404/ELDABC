# Enhanced Labor Division Artificial Bee Colony (ELDABC) Algorithm
The code implementation of ELDABC

## Overview
This repository contains the **fully reproducible MATLAB implementation** of the **Enhanced Labor Division Artificial Bee Colony (ELDABC)** algorithm proposed in our under-review paper.

The code implements all core mechanisms of ELDABC and validates its performance on **two standard benchmark test suites** (consistent with the paper's experiments), enabling reviewers to directly verify the algorithm's effectiveness.

## Environment Requirements
- **MATLAB R2019a or later** (required for `writematrix` function)
- No additional toolboxes required
- IEEE CEC2013 benchmark function files (included in this repo)

## Quick Start
### Step 1: Clone the Repository
Download all files to your local computer.

### Step 2: Open MATLAB
Set the ELDABC folder as the **current working directory** in MATLAB.

### Step 3: Run the Main Program
Execute `main.m` directly in the MATLAB command window: matlab

## Output Results
After execution, the code automatically generates Excel result files in the working directory:

For Test Suite 1 (F22)
    ELDABC_F22_D30.xlsx: Statistical results (Function Index, Best, Mean, Std)
    ELDABC_F22_D30_raw.xlsx: Raw data of all independent runs
    
For Test Suite 2 (CEC2013)
    ELDABC_CEC2013_D30.xlsx: Statistical error results
    ELDABC_CEC2013_D30_raw.xlsx: Raw error data
    
All results can be directly compared with the experimental tables in the manuscript.

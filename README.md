# Large-Scale Behavioral Data Integration Pipeline

## Overview

This project implements a reproducible R-based data integration and preprocessing pipeline designed to consolidate fragmented behavioral datasets distributed across multiple Excel workbooks and hundreds of sheets into a unified analytical framework.

The workflow was developed for large-scale behavioral and language-development research settings where raw observational data were stored in heterogeneous spreadsheet structures with inconsistent naming conventions and semi-structured formatting.

Rather than performing simple row-binding operations, the pipeline applies goal-oriented extraction, restructuring, transformation, and aggregation procedures to generate analysis-ready participant-level variables from fragmented transcription-based datasets.

Due to research confidentiality and data-sharing restrictions, the original datasets are not included in this repository.

---

## Project Objectives

The pipeline was designed to:

* Automatically detect and extract relevant sheets across multiple Excel files
* Standardize inconsistent multilingual character encodings and naming structures
* Convert fragmented spreadsheet-based observational records into structured analytical data
* Generate participant-level summary variables from transcription-level observations
* Reduce manual preprocessing and improve reproducibility across large datasets
* Support scalable downstream statistical analyses and behavioral modeling workflows

---

## Dataset Structure

The original dataset consisted of:

* 13 Excel workbooks
* 400+ sheets
* Semi-structured transcription tables
* Inconsistent sheet naming conventions
* Heterogeneous variable structures across files

The pipeline dynamically identifies relevant sheets using pattern-based matching and processes them into a standardized analytical format.

---

## Core Features

### Automated Sheet Discovery

The pipeline programmatically scans Excel workbooks and identifies target sheets using pattern-matching procedures.

### Character Normalization

Custom normalization functions standardize Turkish-specific characters and inconsistent text encodings to improve matching reliability across files.

### Dynamic Variable Formulation

A generalized variable-generation framework enables flexible computation of participant-level variables using reusable operation definitions.

### Scalable Data Integration

The workflow restructures fragmented observational records into a unified participant-level dataset suitable for downstream statistical analysis.

### Automated Feature Extraction

The system automatically derives summary variables including:

* lexical causal markers
* morphological causal markers
* conjunction usage
* word counts
* vocabulary diversity metrics

across multiple experimental conditions.

---

## Technologies Used

* R
* readxl
* stringi
* tibble
* here

---

## Analytical Workflow

1. Detect Excel workbooks within the project directory
2. Extract sheet names and standardize text formatting
3. Match sheets using predefined experimental patterns
4. Import transcription-based spreadsheet data
5. Detect relevant transcription columns dynamically
6. Clean and restructure observational records
7. Generate participant-level summary variables
8. Aggregate outputs into a unified analytical dataset

---

## Repository Note

This repository focuses on the preprocessing architecture and analytical workflow design underlying large-scale behavioral data integration.

The raw datasets and derived outputs are not publicly available due to confidentiality restrictions associated with the original research project.

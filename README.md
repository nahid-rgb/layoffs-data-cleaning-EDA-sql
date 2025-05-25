# Layoffs Dataset: Data Cleaning & EDA with SQL

This project demonstrates a complete SQL workflow — from data cleaning to exploratory data analysis — using a real-world layoffs dataset.

**Dataset Source**:  
The dataset was downloaded from Kaggle: [Layoffs Dataset on Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022)  
Since this dataset continues to receive updates as new data is added, I have also included the exact Excel file I used (`layoffs.csv`) for reference.

---

## 📊 Dataset Overview

The dataset contains records of company layoffs including:
- Company
- Location
- Industry
- Total Laid Off
- Percentage Laid Off
- Date of Layoff
- Funding Raised
- Stage
- Source
- Country
- Date Added

---

## Data Cleaning Steps

### 1. Create Working Copy
Duplicated original data into a working table for safe cleaning.

### 2. Remove Duplicates
Used `ROW_NUMBER()` to identify and remove duplicate rows.

### 3. Standardize Text Data
Applied `TRIM()` to clean up leading/trailing whitespaces in all string columns.

### 4. Handle Null & Blank Values
- Converted blank strings to `NULL`
- For `percentage_laid_off`, preserved `NULL`s for better handling in analysis
- Removed `%` symbols and casted the column to `FLOAT`
- Normalized `percentage_laid_off` from 0–100 to 0.00–1.00 scale

### 5. Convert Data Types
Converted `date` column from `TEXT` to proper `DATE` format using `STR_TO_DATE`

### 6. Drop Temporary Columns
Dropped the `row_num` helper column used during duplicate detection

---

## Exploratory Data Analysis (EDA)

Performed the following analysis:
- Highest layoffs by company, industry, and country
- Yearly and monthly layoff trends
- Monthly rolling total of layoffs
- Top 5 companies by layoffs per year
- Average & max layoffs
- Average & total layoff percentages
- Layoffs by funding stage

---

## 📁 Files Included

- `layoffs_cleaning_and_eda.sql` — Complete SQL script (cleaning + EDA)
- `layoffs.xlsx` — Original dataset file used in this project
- `README.md` — Project summary

---

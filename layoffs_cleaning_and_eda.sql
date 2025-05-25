-- ----------------------------------
-- Exploratory Data Analysis (EDA) on Layoffs Dataset
-- ----------------------------------
-- 1. Remove Duplicates 
-- 2. Standardize the data 
-- 3. Handle Null and blank values 
-- 4. Drop unnecessary columns

-- View Original Data Count
SELECT COUNT(*) 
FROM layoffs; -- 4068 before cleaning

-- Create a Working Copy of the Data
CREATE TABLE layoffs_modify 
LIKE layoffs;

INSERT INTO layoffs_modify 
SELECT * FROM layoffs;

-- 1. Identify & Remove Duplicates Using ROW_NUMBER()
CREATE TABLE layoffs_modify2 (
  company TEXT,
  location TEXT,
  total_laid_off DOUBLE DEFAULT NULL,
  date TEXT,
  percentage_laid_off TEXT,
  industry TEXT,
  source TEXT,
  stage TEXT,
  funds_raised TEXT,
  country TEXT,
  date_added TEXT,
  row_num INT
);

-- Insert with row numbers to detect duplicates
INSERT INTO layoffs_modify2
SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
    date, stage, country, funds_raised
  ) AS row_num
FROM layoffs_modify;

-- Remove duplicates
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_modify2 WHERE row_num > 1;

-- 2. Standardize the Data
UPDATE layoffs_modify2
SET 
  company = TRIM(company),
  location = TRIM(location),
  industry = TRIM(industry),
  stage = TRIM(stage),
  country = TRIM(country),
  funds_raised = TRIM(funds_raised),
  source = TRIM(source),
  date_added = TRIM(date_added),
  total_laid_off = TRIM(total_laid_off),
  percentage_laid_off = TRIM(percentage_laid_off),
  date = TRIM(date);

-- 3. Handle NULL and Blank Values
-- Check and handle blanks/nulls in important columns manually
-- Keep percentage_laid_off as NULL where missing to preserve for analysis

-- Keeping nulls in percentage_laid_off to reflect missing data accurately and handle them easily during analysis.


UPDATE layoffs_modify2 
SET percentage_laid_off = NULL 
WHERE percentage_laid_off = '';

--  Convert 'date' from TEXT to DATE
UPDATE layoffs_modify2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_modify2
MODIFY COLUMN date DATE;

-- Convert 'percentage_laid_off' to Float
UPDATE layoffs_modify2
SET percentage_laid_off = REPLACE(percentage_laid_off, '%', '');

ALTER TABLE layoffs_modify2
MODIFY COLUMN percentage_laid_off FLOAT;

UPDATE layoffs_modify2
SET percentage_laid_off = percentage_laid_off / 100
WHERE percentage_laid_off IS NOT NULL;

-- 4. Drop Temporary Column
ALTER TABLE layoffs_modify2 DROP COLUMN row_num;

-- -------------------
-- EDA Queries Below
-- -------------------

-- Range of Dates
SELECT MIN(date), MAX(date) 
FROM layoffs_modify2;

-- Companies with Highest Layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_modify2
GROUP BY company
ORDER BY total_laid_off DESC;

-- Industries with Highest Layoffs
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_modify2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Countries with Highest Layoffs
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_modify2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Yearly Layoffs
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_modify2
GROUP BY year
ORDER BY year DESC;

-- Highest Layoff Percentage by Company
SELECT company, ROUND(SUM(percentage_laid_off), 2) AS total_percentage_laid_off
FROM layoffs_modify2
GROUP BY company
ORDER BY total_percentage_laid_off DESC;

-- Average Layoff Percentage by Company
SELECT company, ROUND(AVG(percentage_laid_off), 2) AS avg_percentage_laid_off
FROM layoffs_modify2
GROUP BY company
ORDER BY avg_percentage_laid_off DESC;

-- Layoffs by Stage
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_modify2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- Monthly Layoffs Trend
SELECT LEFT(date, 7) AS month, SUM(total_laid_off) AS monthly_total
FROM layoffs_modify2
WHERE date IS NOT NULL
GROUP BY month
ORDER BY month;

-- Monthly Rolling Total
WITH Monthly_Layoffs AS (
  SELECT LEFT(date, 7) AS month, SUM(total_laid_off) AS monthly_total
  FROM layoffs_modify2
  WHERE date IS NOT NULL
  GROUP BY month
)
SELECT month, monthly_total, 
       SUM(monthly_total) OVER (ORDER BY month) AS rolling_total
FROM Monthly_Layoffs;

-- Top 5 Companies by Year
WITH Company_Year AS (
  SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_modify2
  GROUP BY company, year
),
Company_Year_Rank AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
  WHERE year IS NOT NULL
)
SELECT * FROM Company_Year_Rank
WHERE ranking <= 5;

-- Average Layoffs Per Company
SELECT ROUND(AVG(total_laid_off), 2) AS avg_laid_off
FROM layoffs_modify2;

-- Maximum and Minimum Layoffs in Any Single Row
SELECT MAX(total_laid_off) AS max_laid_off,
       MIN(total_laid_off) AS min_laid_off
FROM layoffs_modify2; -- 

-- Total Layoff Percentage by Industry
SELECT industry, ROUND(SUM(percentage_laid_off), 2) AS total_percentage_laid_off
FROM layoffs_modify2
WHERE percentage_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_percentage_laid_off DESC;




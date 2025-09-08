
-- Data Cleaning Project -- 

SELECT * 
FROM layoffs;

-- 1° Remove Duplicates 
-- 2° Standardize Data
-- 3° Blank Value
-- 4° Remove useless Colums 


CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

SELECT * 
FROM layoffs_staging;

SELECT *,
ROW_NUMBER () OVER (PARTITION BY 
	company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, 
    country, funds_raised_millions) AS 'row_number'
FROM layoffs_staging; 

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER () OVER (PARTITION BY 
	company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, 
    country, funds_raised_millions) AS row_num
FROM layoffs_staging 
)

SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER () OVER (PARTITION BY 
	company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, 
    country, funds_raised_millions) AS row_num
FROM layoffs_staging;
 
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
	WHERE industry LIKE'Crypto%';
    
SELECT industry, company
FROM layoffs_staging2
WHERE company IN ('Airbnb', 'Bally''s Interactive', 'Carvana', 'Juul');

UPDATE layoffs_staging2 
SET industry = NULL
WHERE industry = '';

-- Airbnb  Travel 
-- Bally's Interactive Retail  
-- Carvana  Marketing 
-- Juul  Product

UPDATE layoffs_staging2 
SET industry = "Travel"
WHERE company = "Airbnb";

UPDATE layoffs_staging2 
SET industry = "Retail"
WHERE company = "Bally's Interactive";

UPDATE layoffs_staging2 
SET industry = "Marketing"
WHERE company = "Carvana";

UPDATE layoffs_staging2 
SET industry = "Product"
WHERE company = "Juul";

SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
	AND percentage_laid_off IS NULL;
    
DELETE
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
	AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2 
	DROP COLUMN row_num ;

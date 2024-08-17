CREATE SCHEMA Project22;

SELECT * FROM hresource;

-- DATA CLEANING and PREPROCESSING --

ALTER TABLE hresource
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hresource;

-- birthdate format and datatype change--
SELECT birthdate FROM hresource;

UPDATE hresource
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
    END;

ALTER TABLE hresource
MODIFY COLUMN birthdate DATE;

-- hire_date format and datatype change--
SELECT hire_date FROM hresource;
UPDATE hresource
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
    END;
ALTER TABLE hresource
MODIFY COLUMN hire_date DATE;

-- termdate format and datatype change--
SELECT termdate FROM hresource;
UPDATE hresource
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

UPDATE hresource
SET termdate = null
WHERE termdate = '';

-- adding a column age --
ALTER TABLE hresource
ADD COLUMN age INT;

SELECT * from hresource;

UPDATE hresource
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT age from hresource;
SELECT 
min(age) as youngest,
max(age) as oldest
FROM hresource;

-- looking for duplicates --
SELECT COUNT(emp_id)
FROM hresource;
SELECT COUNT(DISTINCT(emp_id))
FROM hresource;
-- Found no duplicates

SELECT * FROM hresource;
SELECT DISTINCT(gender)
FROM hresource;
SELECT DISTINCT(location_state)
FROM hresource;

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, count(*) as count
FROM hresource
WHERE termdate is NULL
GROUP BY gender;

-- 2. What is the race breakdown of employees in the company?
SELECT race, count(*) as count
FROM hresource
WHERE termdate is NULL
GROUP BY race;

-- 3. What is the age distribution of employees in the company?
SELECT 
	CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
    FROM hresource
    WHERE termdate is null
    GROUP BY age_group
    ORDER BY age_group;
    
    SELECT * FROM hresource;
    -- 4. How many employees work at HQ vs remote?
SELECT location, COUNT(*) AS count
FROM hresource
WHERE termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employement who have been teminated?
SELECT  ROUND(AVG(year(termdate) - year(hire_date))) AS length_of_employment
FROM hresource
WHERE termdate IS NOT NULL AND termdate<=curdate();

-- 6. How does the gender distribution vary acorss dept. and job titles?
SELECT department,jobtitle,gender,COUNT(*) AS count
FROM hresource
WHERE termdate IS NULL
GROUP BY department, jobtitle,gender
ORDER BY department, jobtitle,gender;

SELECT department,gender,COUNT(*) AS count
FROM hresource
WHERE termdate IS NULL
GROUP BY department,gender
ORDER BY department,gender;

-- 7. What is the distribution of jobtitles acorss the company?
SELECT jobtitle, COUNT(*) AS count
FROm hresource
WHERE termdate IS NULL
GROUP BY jobtitle;

    SELECT * FROM hresource;
-- 8. Which dept has the higher turnover/termination rate?
SELECT department, COUNT(*) AS total_count,
	COUNT(CASE
			WHEN termdate is NOT NULL AND termdate<=curdate() THEN 1
            END) AS terminated_count,
	ROUND((COUNT(CASE
			WHEN termdate is NOT NULL AND termdate<=curdate() THEN 1
            END)/COUNT(*))*100,2) AS termination_rate
	FROM hresource
    GROUP BY department
    ORDER BY termination_rate DESC;
    
-- 9. What is the distribution of employees across location state and location city
SELECT location_state, COUNT(*) AS count
FROm hresource
WHERE termdate IS NULL
GROUP BY location_state;

SELECT location_city, COUNT(*) AS count
FROm hresource
WHERE termdate IS NULL
GROUP BY location_city;

-- 10. How has the companys employee count changed over time based on hire and termination date.
SELECT hire_year,
		hires,
        terminations,
        hires-terminations AS net_change,
        (terminations/hires)*100 AS change_percent
	FROM(
			SELECT YEAR(hire_date) AS hire_year,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
			FROM hresource
            GROUP BY YEAR(hire_date)) AS subquery
ORDER BY hire_year;

-- 11. What is the tenure distribution for each dept?
SELECT department, round(avg(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM hresource
WHERE termdate IS NOT NULL AND termdate<= curdate()
GROUP BY department
ORDER BY avg_tenure;

-- termination and hire breakdown gender wise
SELECT gender,
		hires,
        terminations,
        (terminations/hires)*100 AS change_percent
	FROM(
			SELECT gender,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
			FROM hresource
            GROUP BY gender) AS subquery
ORDER BY gender;

-- termination and hire breakdown gender wise
SELECT age,
		hires,
        terminations,
        (terminations/hires)*100 AS change_percent
	FROM(
			SELECT age,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
			FROM hresource
            GROUP BY age) AS subquery
ORDER BY age;

-- termination and hire breakdown department wise
SELECT department,
		hires,
        terminations,
        (terminations/hires)*100 AS change_percent
	FROM(
			SELECT department,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
			FROM hresource
            GROUP BY department) AS subquery
ORDER BY department;

-- termination and hire breakdown race wise
SELECT race,
		hires,
        terminations,
        (terminations/hires)*100 AS change_percent
	FROM(
			SELECT race,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
			FROM hresource
            GROUP BY race) AS subquery
ORDER BY race;

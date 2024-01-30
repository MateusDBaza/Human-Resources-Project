CREATE DATABASE company_hr;

USE company_hr;


SELECT * FROM hr;

DESCRIBE hr;

SELECT birthdate FROM hr;

SET  sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
   WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
   WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
   ELSE NULL
   END;
   
   
   ALTER TABLE hr
   MODIFY COLUMN birthdate DATE;
   
UPDATE hr
SET hire_date = CASE
   WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
   WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
   ELSE NULL
   END;
   
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
 
SET sql_mode = '';

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
   WHERE termdate IS NOT NULL AND termdate != ' ';
   
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

 ALTER TABLE hr ADD COLUMN age INT;
 
 UPDATE hr
 SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
MIN(age) AS youngest,
MAX(age) AS oldest FROM hr;

SELECT COUNT(*) FROM hr
WHERE age < 18;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?

SELECT gender, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate != '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race 
ORDER BY count(*) DESC;

-- 3. What is the age distribution of employees in the company?

SELECT 
MIN(age) AS youngest,
MAX(age) AS oldest  FROM hr
WHERE age >= 18 AND termdate = '0000-00-00';

SELECT 
   CASE 
	 WHEN age >= 18 AND age <= 24 THEN '18-24'
     WHEN age >= 25 AND age <= 34 THEN '25-34'
     WHEN age >= 35 AND age <= 44 THEN '35-44'
     WHEN age >= 45 AND age <= 54 THEN '45-54'
     WHEN age >= 55 AND age <= 64 THEN '55-64'
     ELSE '65+'
   END AS age_group,gender,
   COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?

SELECT location, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT 
ROUND(AVG(datediff(termdate, hire_date)) / 365,0) AS avg_length_employment 
FROM hr
WHERE termdate <= curdate() AND termdate !='0000-00-00' AND age >= 18;

-- datediff() returns the number in days, since hiredate and terminate date, I divided by 365 to get the length of employment in years.

-- 6. How does the gender distribution vary across departments and job titles?

SELECT department, gender, COUNT(*) AS count
FROM hr
WHERE  age >= 18 AND termdate = '0000-00-00'
GROUP BY department,gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE  age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle;

-- 8. Which department has the highest turnover rate?

SELECT department,
       total_count,
       terminated_count,
       terminated_count/total_count AS termination_rate
FROM (
    SELECT department,
    Count(*) AS total_count,
    SUM(CASE WHEN termdate != '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery_department
    ORDER BY termination_rate DESC;


-- 9. What is the distribution of employees across locations state and city?

SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY location_state DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
-- This query groups the employees by the year of their hire date and calculates the total number of hires,
-- terminations, and net change (the difference between hires and terminations) for each year. The results are sorted by year in ascending order.

SELECT
       YEAR(hire_date) AS year,
       COUNT(*) AS hires,
       SUM(CASE WHEN termdate != '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS termination,
       COUNT(*) - SUM(CASE WHEN termdate != '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS empl_net_change,
       ROUND((COUNT(*) - SUM(CASE WHEN termdate != '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END)) / COUNT(*) * 100,2) AS net_change_percent
FROM hr
     WHERE age >= 18
GROUP BY YEAR(hire_date)
ORDER BY YEAR(hire_date) ASC;
       
-- 11. What is the tenure distribution for each department?


SELECT department, ROUND(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure 
FROM hr
WHERE termdate <= curdate() AND termdate != '0000-00-00' AND age >= 18
GROUP BY department
ORDER BY avg_tenure DESC;

   
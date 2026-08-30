-- create database named sql_tutorial
CREATE DATABASE `sql_tutorial`;

-- work with sql_tutorial database
USE sql_tutorial;

-- create departments table
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

-- insert data into departments table
INSERT INTO departments(department_id, department_name)
VALUES
(101, 'Finance'),
(102, 'IT'),
(103, 'Sales'),
(104, 'Operations'),
(105, 'Customer Service'),
(106, 'HR'),
(107, 'Marketing'),
(108, 'Accounting'),
(110, 'Research');

-- create jobs table
CREATE TABLE jobs (
    jobcode INT PRIMARY KEY,
    job_title VARCHAR(50)
);

INSERT INTO jobs
(jobcode, job_title)
VALUES
(101,'Data Analyst'),
(102,'HR Officer'),
(103,'Software Engineer'),
(104,'Accountant'),
(105,'Project Manager');

-- create  employees table
CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    department_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    jobcode INT,
    salary INT,
    FOREIGN KEY (department_id)
        REFERENCES departments (department_id),
    FOREIGN KEY (jobcode)
        REFERENCES jobs (jobcode)
);

-- insert data into employees table
INSERT INTO employees
(emp_id, department_id, first_name, last_name, jobcode, salary)
VALUES
('EMP001',106,'Abby','Ajibola',101,250000),
('EMP002',102,'John','Doe',102,180000),
('EMP003',103,'Mary','Smith',103,300000),
('EMP004',101,'David','Brown',104,220000),
('EMP005',102,'Grace','Wilson',102,195000),
('EMP006',104,'Michael','Johnson',105,270000),
('EMP007',105,'Sarah','Davis',101,165000),
('EMP008',106,'Daniel','Miller',103,210000),
('EMP009',107,'Jane','Thomas',102,185000),
('EMP010',108,'Peter','White',104,240000),
('EMP011',101,'Nancy','Taylor',105,320000),
('EMP012',110,'James','Anderson',103,290000),
('EMP013',108,'Chris','Jackson',101,175000),
('EMP014',NULL,'Linda','Moore',102,200000),
('EMP015',103,'Andrew','Martin',104,260000),
('EMP016',105,'Sophia','Clark',105,170000),
('EMP017',102,'Emma','Lewis',101,215000),
('EMP018',104,'Noah','Walker',103,280000),
('EMP019',107,'Olivia','Hall',104,235000),
('EMP020',NULL,'Samuel','Young',102,190000);


-- insert more data into departments and employees tables
INSERT INTO departments(department_id, department_name)
VALUES 
(109, ' '),
(112, 'Business Administrative'),
(113, 'Front Desk Management'),
(114, 'Auditing and Inventory Management'),
(115, 'Data Science');

INSERT INTO employees
(emp_id, department_id, first_name, last_name, jobcode, salary)
VALUES 
('EMP106', 109, 'Job', 'Ugo', 101, 60000);

-- verify data entry
SELECT 
    *
FROM
    employees
WHERE
    first_name LIKE 'jo%';


## Practice Inner Join
## Inner join combines rows that are matching in the tables

-- find employees with their department names
SELECT 
    e.first_name, e.last_name, d.department_name
FROM
    employees e
        INNER JOIN
    departments d ON e.department_id = d.department_id;


## Practice Left Join
## Left Join returns all values in table 1

-- find employees from with their department, even if they are not assigned any department
SELECT 
    e.first_name, e.last_name, d.department_name
FROM
    employees e
        LEFT JOIN
    departments d ON e.department_id = d.department_id;

## Practice Right Join
## Right Join returns all values in table 2

-- find departments available and their employees, even if they don't have employees
SELECT 
    d.department_id,
    d.department_name,
    e.first_name,
    e.last_name
FROM
    employees e
        RIGHT JOIN
    departments d ON e.department_id = d.department_id;

-- find departments, employees and job title, include all departments even if they don't have employees (joining three tables)
SELECT 
    d.department_id,
    d.department_name,
    e.first_name,
    e.last_name,
    j.job_title
FROM
    employees e
        RIGHT JOIN
    departments d ON d.department_id = e.department_id
        LEFT JOIN
    jobs j ON e.jobcode = j.jobcode
GROUP BY d.department_id;

## Practice Full Outer Join
## use Union (set operator) instead of full outer join because full outer join is not available on mysql

-- combine data from both employees and departments tables without missing any rows
SELECT 
    d.department_name, e.first_name, e.last_name
FROM
    employees e
        LEFT JOIN
    departments d ON e.department_id = d.department_id 
UNION SELECT 
    d.department_name, e.first_name, e.last_name
FROM
    employees e
        RIGHT JOIN
    departments d ON e.department_id = d.department_id;

## Practice Subqueries (first query is the outer query while the second is the subquery)

-- get employees and department earning above average salary
SELECT 
    e.first_name, e.last_name, salary, d.department_name
FROM
    employees e
        JOIN
    departments d ON e.department_id = d.department_id
WHERE
    salary > (SELECT 
            AVG(salary)
        FROM
            employees e
        WHERE
            department_id = e.department_id);
    
# Practice Intersect - set operators
# Intersect does not exist in Mysql

-- list department names not yet associated with employees
SELECT 
    d.department_name
FROM
    departments d
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            employees e
        WHERE
            e.department_id = d.department_id);
	
## Practice Row_number() - window function

-- number of employees by department using Row_number function
SELECT first_name, last_name, department_id,
		ROW_NUMBER() OVER (PARTITION by department_id ORDER BY e.first_name, e.last_name) AS row_num
FROM employees e;

## Practice Rank() - window function

-- rank employees by salary in each department
SELECT first_name, last_name, department_id, salary,
	RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS ranking
FROM employees;

-- add new column (performance_score) to employees table
ALTER TABLE employees
ADD performance_score INT;

-- add data to new column - performance_score
UPDATE employees 
SET 
    performance_score = CASE emp_id
        WHEN 'EMP001' THEN 75
        WHEN 'EMP002' THEN 87
        WHEN 'EMP003' THEN 98
        WHEN 'EMP004' THEN 96
        WHEN 'EMP005' THEN 69
        WHEN 'EMP006' THEN 78
        WHEN 'EMP007' THEN 79
        WHEN 'EMP008' THEN 89
        WHEN 'EMP009' THEN 87
        WHEN 'EMP010' THEN 78
        WHEN 'EMP011' THEN 98
        WHEN 'EMP012' THEN 78
        WHEN 'EMP013' THEN 89
        WHEN 'EMP014' THEN 87
        WHEN 'EMP015' THEN 56
        WHEN 'EMP016' THEN 67
        WHEN 'EMP017' THEN 87
        WHEN 'EMP018' THEN 89
        WHEN 'EMP019' THEN 78
        WHEN 'EMP020' THEN 89
        WHEN 'EMP106' THEN 90
    END
WHERE
    emp_id IN ('EMP001' , 'EMP002',
        'EMP003',
        'EMP004',
        'EMP005',
        'EMP006',
        'EMP007',
        'EMP008',
        'EMP009',
        'EMP010',
        'EMP011',
        'EMP012',
        'EMP013',
        'EMP014',
        'EMP015',
        'EMP016',
        'EMP017',
        'EMP018',
        'EMP019',
        'EMP020',
        'EMP106');

## Practice Lead and Lag - window functions

-- how does an employee's salary or performance score compare to their previous and next evaluation within their department
SELECT 
	e.first_name, 
    e.last_name, 
    e.department_id, 
    e.salary,
    e.performance_score,
    LAG(e.salary) OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS previous_salary,
    LEAD(e.salary) OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS next_salary,
    LAG(e.performance_score) OVER (PARTITION BY e.department_id ORDER BY e.performance_score DESC) AS previous_score,
    LEAD(e.performance_score) OVER (PARTITION BY e.department_id ORDER BY e.performance_score DESC) AS next_score
FROM employees e;

## Practice Common Table Expression (CTE)
## Note: you start CTE with WITH followed by CTE_name (temporary table name)

-- find the total salary paid by each department using CTE
WITH DepartmentSalaries AS (
			SELECT e.department_id, SUM(e.salary) AS TotalSalary
            FROM employees e
            GROUP BY e.department_id
            )
SELECT d.department_name, ds.TotalSalary
FROM departments d
LEFT JOIN DepartmentSalaries ds
ON d.department_id = ds.department_id
ORDER BY ds.TotalSalary DESC;

## Practice grouping sets and Rollup
## Use rollup instead of group set since it is not available on Mysql
## rollup is is an extension of the group by clause that allows user to add extra rows that represent subtotals, which are sometimes referred to as super-aggregate rows.

-- summarise salary by department and overall total (grand total)
SELECT d.department_name, SUM(e.salary) AS TotalSalary
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
GROUP BY department_name WITH ROLLUP;

## Practice CUBE
## Cube is an extension of the group by clause that generate subtotals for combinations of grouping columns specified in the group by clause.
## Cube is not available on mysql, use rollup and union to get result

/* Generate a report that shows total salary for all combinations of all department and  performance rating.
Use the CUBE operation to include subtotal for each department, each performance rating and the grand total.*/

#Subtotals for department and performance rating.
SELECT 
	IFNULL(d.department_name, 'All Departments') AS department_name,
	IFNULL(e.performance_score, 'All Ratings') AS performance_rating,
	SUM(e.salary) AS Total_Salary
FROM employees e
LEFT JOIN departments d
ON e.department_id = d.department_id
GROUP BY d.department_name, e.performance_score WITH ROLLUP

UNION ALL

#Subtotals for performance _rating only
SELECT
	'All Departments' AS department_name,
    IFNULL(e.performance_score, 'All Ratings') AS performance_ratings,
    SUM(e.salary) AS Total_Salary
FROM employees e
LEFT JOIN departments d
ON e.department_id = d.department_id
GROUP BY e.performance_score WITH ROLLUP
HAVING
department_name IS NOT NULL OR performance_score IS NOT NULL
ORDER BY 
department_name, performance_rating, Total_Salary;

## Practice Upper() - string function

-- Convert employee names to Uppercase
SELECT 
	UPPER(e.first_name) AS formatted_first_name,
    UPPER(e.last_name) AS formatted_last_name
FROM employees e;

## Practice CONCAT() - string function

#Add new table name into employees table
ALTER TABLE employees
ADD name VARCHAR (50);

-- concatenate the employee first and last name as name
-- use concat_ws incase there is a null value in one of the columns
UPDATE employees
SET name = CONCAT_WS(' ', first_name, last_name)
WHERE emp_id IN ('EMP001' , 'EMP002',
        'EMP003',
        'EMP004',
        'EMP005',
        'EMP006',
        'EMP007',
        'EMP008',
        'EMP009',
        'EMP010',
        'EMP011',
        'EMP012',
        'EMP013',
        'EMP014',
        'EMP015',
        'EMP016',
        'EMP017',
        'EMP018',
        'EMP019',
        'EMP020',
        'EMP106');
        
-- verify values in new column
SELECT e.emp_id,
		e.name,
        d.department_name
FROM employees e
LEFT JOIN departments d
ON e.department_id = d.department_id;

## Practice dropping columns
-- remove the newly added column - name
ALTER TABLE employees
DROP COLUMN name;

-- verify if column has been dropped
SELECT *
FROM employees e
LIMIT 2;

## Practice Curdate(), datediff() - date function

-- calculate the number of days since an employee was hired
#Add new column hire_date
ALTER TABLE employees
ADD hire_date DATE;

#Add values into column hire_date
UPDATE employees
SET hire_date = CASE emp_id
		WHEN 'EMP001' THEN '2018-03-10'
        WHEN 'EMP002' THEN '2021-05-20'
        WHEN 'EMP003' THEN '2019-08-29'
        WHEN 'EMP004' THEN '2015-12-02'
        WHEN 'EMP005' THEN '2018-12-04'
        WHEN 'EMP006' THEN '2012-09-09'
        WHEN 'EMP007' THEN '2018-07-09'
        WHEN 'EMP008' THEN '2018-03-10'
        WHEN 'EMP009' THEN '2018-07-09'
        WHEN 'EMP010' THEN '2018-03-10'
        WHEN 'EMP011' THEN '2019-08-29'
        WHEN 'EMP012' THEN '2019-08-29'
        WHEN 'EMP013' THEN '2019-08-29'
        WHEN 'EMP014' THEN '2018-03-10'
        WHEN 'EMP015' THEN '2018-03-10'
        WHEN 'EMP016' THEN '2018-03-10'
        WHEN 'EMP017' THEN '2018-09-09'
        WHEN 'EMP018' THEN '2019-09-10'
        WHEN 'EMP019' THEN '2025-06-12'
        WHEN 'EMP020' THEN '2025-06-12'
        WHEN 'EMP106' THEN '2025-06-12'
	END
WHERE
    emp_id IN ('EMP001' , 'EMP002',
        'EMP003',
        'EMP004',
        'EMP005',
        'EMP006',
        'EMP007',
        'EMP008',
        'EMP009',
        'EMP010',
        'EMP011',
        'EMP012',
        'EMP013',
        'EMP014',
        'EMP015',
        'EMP016',
        'EMP017',
        'EMP018',
        'EMP019',
        'EMP020',
        'EMP106');

#get days since an employee was hired
SELECT  e.first_name,
		e.last_name,
		hire_date,
        DATEDIFF(CURDATE(), hire_date) AS Days_Since_Hired
FROM employees e;

## Practice CASE statement and conditional aggregation

-- Find the total salary by department, but split it into salaries above 100,000 and below 100,000	
SELECT d.department_name,
		SUM(CASE WHEN e.salary >= 100000 THEN e.salary ELSE 0 END) AS high_salaries,
        SUM(CASE WHEN e.salary < 100000 THEN e.salary ELSE 0 END) AS low_salaries
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
GROUP BY d.department_name;
			
## Practice Indexing

-- Create an index on employee_id to improve query performance
CREATE INDEX idx_emp_id ON employees(emp_id);

-- Confirm query output speed
SELECT *
FROM employees;

SELECT *
FROM employees
WHERE emp_id = 'EMP020';

## Practice EXPLAIN and ANALYZE command to aid the comprehension on SQL query execution

-- Use Explain to analyze a query that retrieves employee details by department
EXPLAIN 
SELECT e.first_name, d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

ANALYZE
SELECT 
    e.first_name,
    d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

# This gives you more actual execution information in nested format
ANALYZE FORMAT = JSON
SELECT 
    e.first_name,
    d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

# Profiling allows user to record the exact time used to execute a query
# Profiling = 1 means start whil 0 means stop

SET profiling = 1;

SELECT 
    e.first_name,
    d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

SHOW PROFILES;

# This gives breakdown for the executing a particular query on the profile table
SHOW PROFILE FOR QUERY 1;

# This turn off the profiling
SET profiling = 0;

# Practice Normalisation

CREATE TABLE employeephonenumber(
	id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id VARCHAR (50),
    phone_number VARCHAR(15),
    FOREIGN KEY (emp_id)
		REFERENCES employees (emp_id));
        
INSERT INTO employeephonenumber(emp_id, phone_number)
VALUES
('EMP001' , 8100056239),
('EMP002', 70123456788),
('EMP003', 7023457898),
('EMP004', 8129783456),
('EMP005', 9012345678),
('EMP006', 9012347898),
('EMP007', 0912786545),
('EMP008', 8012786578),
('EMP009', 9087652435),
('EMP010', 9087675643),
('EMP011', 8056435676),
('EMP012', 8096785678),
('EMP013', 9087655467),
('EMP014', 8076876567),
('EMP015', 9056342689),
('EMP016', 8067453456),
('EMP017', 9087456789),
('EMP018', 9056857899),
('EMP019', 9075757578),
('EMP020', 7098989898),
('EMP106', 9089675687);

# verify table content 
SELECT * 
FROM employeephonenumber;

#SQL tutorial script by abbydata
	
 
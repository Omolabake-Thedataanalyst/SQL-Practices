# Practice schema creation
## create new schema - hrms through menu navigation

-- specify schema to use
USE hrms;

## create employee table with two foreign keys
CREATE TABLE employees (
	employee_id INT PRIMARY KEY,
    employee_name VARCHAR (100),
    department_id INT,
    manager_id INT,
    FOREIGN KEY (department_id)
		REFERENCES departments(department_id),
	FOREIGN KEY (manager_id)
		REFERENCES managers(manager_id)
        );
	
## insert into employees table
INSERT INTO employees
(employee_id, employee_name, department_id, manager_id)
VALUES
(101, 'Charles Eze', 1001, 201),
(102, 'Martins Osas', 1002, 202),
(103, 'Job Olu', 1001, 201),
(104, 'David Martins', 1003, 203);

## create department table
CREATE TABLE departments (
	department_id INT PRIMARY KEY,
    department_name VARCHAR (20),
    department_location VARCHAR (100)
    );
    
## insert data into departments
INSERT INTO departments
(department_id, department_name, department_location)
VALUES
(1001, 'IT', 'Kano'),
(1002, 'HR', 'Anambra'),
(1003, 'IT', 'Ogun'),
(1004, 'Finance', 'Bayelsa');

## create managers table
CREATE TABLE managers (
	manager_id INT PRIMARY KEY,
    department_id INT,
    FOREIGN KEY (department_id)
		REFERENCES departments(department_id)
        );

## insert data into manager table
INSERT INTO managers
(manager_id, department_id)
VALUES
(201, 1001),
(202, 1002),
(203, 1003),
(204, 1004);

-- specify database to use
use sql_tutorial;

#### Practicing ETL on SQL
## extract data from csv into department database
## confirm data import
SELECT * 
FROM departments;

###Transform data
## handle missing and wrong data in department table
UPDATE departments
SET department_name = 'Developers'
WHERE department_id = 103;

UPDATE departments
SET department_name = 'Unknown'
WHERE department_id = 109;

## create a final department table
CREATE TABLE finaldepartments(
	department_id INT PRIMARY KEY,
    department_name VARCHAR (50)
	);

## load our clean data into department final_table    
INSERT INTO finaldepartments(department_id, department_name)
SELECT * FROM departments;

# confirm data in the new table - finaldepartments
SELECT * FROM finaldepartments;

# Practice Online Transactional Processing (OLTP)
/* A company's payroll system records salaries in real time. When an employee gets a salary raise, the database updates immediately
and also the manager wants to analyze salary trends and find the top 3 - highest paid employees in each department to identify pay disparities. */

## create a table of salary history
CREATE TABLE salary_history (
	id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id VARCHAR(50) NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id)
		REFERENCES employees (emp_id)
        );

## create a trigger for after salary update
DELIMITER $$
CREATE TRIGGER after_salary_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN 
	IF OLD.salary <> NEW.salary THEN
    INSERT INTO salary_history(emp_id, old_salary, new_salary, change_date)
    VALUES (NEW.emp_id, Old.salary, NEW.salary, NOW());
    END IF;
END $$
DELIMITER ;

SELECT *
FROM employees;

## update one of the employees salary
UPDATE employees
SET salary = 700000
WHERE emp_id = 'EMP003';

#
SELECT *
FROM salary_history;

## find the top 3 highest paid employees in each department
SELECT emp_id, first_name, last_name, salary, department_name, `rank`
FROM (
	SELECT e.emp_id, e.first_name, e.last_name, e.salary, d.department_name,
    RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS 'rank'
    FROM employees e
    LEFT JOIN departments d
    ON e.department_id = d.department_id
    ) AS rank_employees
WHERE `rank` <= 3;

## find the highest paid employees in each department
SELECT emp_id, first_name, last_name, salary, department_name, `rank`
FROM (
	SELECT e.emp_id, e.first_name, e.last_name, e.salary, d.department_name,
	RANK() OVER(PARTITION BY d.department_name ORDER BY e.salary DESC) AS 'rank'
	FROM employees e
	JOIN departments d
	ON e.department_id = d.department_id) AS rank_employees
WHERE `rank` = 1;

## Practice VIEW in SQL
/* create a SQL view that displays employee details including their employee ID, name, salary and the department name they belong to. 
Use the employees and departments tables, where employees are linked to departments using department_id. */
CREATE VIEW employeesdetails AS
	SELECT e.emp_id, e.first_name, e.last_name, d.department_name, e.salary
    FROM employees e
    JOIN departments d
    ON e.department_id = d.department_id;

SELECT *
FROM employeesdetails;

## Create a materialized view that stores the total salary paid by department
# create the department total salary summary table
CREATE TABLE department_salary_summary (
	department_id INT PRIMARY KEY,
    total_salary DECIMAL (10,2),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    );
    
## create a procedure to refresh the materialized view
DELIMITER $$

CREATE PROCEDURE refresh_materialized_view()
BEGIN
-- update existing records or insert new ones
	REPLACE INTO department_salary_summary (department_id, total_salary)
    SELECT department_id, SUM(salary)
    FROM employees
    WHERE department_id IS NOT NULL
    GROUP BY department_id;
END $$

DELIMITER ;

## call Materialized view for testing
CALL refresh_materialized_view();
SELECT * 
FROM department_salary_summary;

## Practice stored procedure

## create a stored procedure that retrieves all employees who joined within a given date range.
# create procedure
DELIMITER $$
CREATE PROCEDURE GetEmployeesByJoinDate (
	IN start_date DATE,
    IN end_date DATE
    )
BEGIN
	SELECT emp_id, first_name, last_name, department_id, hire_date
    FROM employees
    WHERE hire_date BETWEEN start_date AND end_date;
END $$
DELIMITER ;

## Call employees using stored procedure
CALL GetEmployeesByJoinDate ('2018-03-10', '2025-12-26');

/* write a stored procedure in MYSQL that retrieves employees details from an employees table based on a given employee id. 
The procedure should take employee id as an input parameter and return the employee's details. */

# create procedure
DELIMITER $$
CREATE PROCEDURE GetEmployeesDetailsByID (
	IN p_emp_id VARCHAR(50)
    )
BEGIN
	SELECT e.emp_id, e.first_name, e.last_name, d.department_name, e.hire_date, e.performance_score
    FROM employees e
    JOIN departments d
    ON e.department_id = d.department_id
    WHERE emp_id = p_emp_id;
END $$
DELIMITER ;

# get employees details using stored procedure
CALL GetEmployeesDetailsByID ('EMP009');

## Practice Transaction in SQL
## Using the given SQL script, explain how money is transferred between two accounts using a transaction.
CREATE TABLE accounts (
	account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_holder VARCHAR(100) NOT NULL,
    balance DECIMAL(10,2)
    );

## insert records into accounts
INSERT INTO accounts (account_holder, balance)
VALUES
('Alice', 2000),
('Bob', 1500);

## Create a procedure to transfer
DELIMITER $$
CREATE PROCEDURE transfer_money(
	IN sender_id INT, 
    IN receiver_id INT, 
    IN amount DECIMAL(10,2)
    )
BEGIN 
	DECLARE sender_balance DECIMAL (10,2);
-- start transaction
START TRANSACTION;
-- get the sender balance
SELECT balance into sender_balance 
FROM accounts 
WHERE account_id = sender_id;
-- check if sender has enough balance
IF sender_balance < amount THEN
-- Rollback if insufficient
	ROLLBACK;
ELSE
-- deduct amount from sender account
UPDATE accounts
SET balance = balance - amount
WHERE account_id = sender_id;
-- add amount to the receiver account
UPDATE accounts
SET balance = balance + amount
WHERE account_id = receiver_id;
-- commit the transaction
COMMIT;
END IF;
END $$
DELIMITER ;

-- transfer money using procedure
CALL transfer_money (1, 2, 500);

# confirm balances
SELECT * FROM accounts;

## Practice Error handling in SQL

# let's look at an example where you are attempting to divide a number by zero, which is against the law.

DELIMITER $$
CREATE PROCEDURE DivideNumbers()
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error: Division by zero occured' AS ErrorMessage;
	END;
-- Attempt division by zero
SELECT 5/0 AS Result;
END $$
DELIMITER ;

-- use stored procedure
CALL DivideNumbers();

## Practice secondary index

/* Suppose you frequently query the department column to filter employees by their department, you can create a secondary index 
(index developed on non-unique or commonly used columns in queries for sorting and filtering) on the department column to speed up queries. */

CREATE INDEX idx_department ON employees(department_id);

## check index performance
SELECT * 
FROM employees
WHERE department_id = 109;

## Practice Partitioning

# Horizontal partitioning
CREATE TABLE employees_horizontal_partition(
	emp_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT NOT NULL,
    salary DECIMAL (10,2),
    PRIMARY KEY (emp_id, department_id)
    )
    PARTITION BY RANGE(department_id) (
    PARTITION p1 VALUES LESS THAN (10),
    PARTITION p2 VALUES LESS THAN (20),
    PARTITION p3 VALUES LESS THAN MAXVALUE
    );
    
-- Insert records into employees_horizontal_partition
INSERT INTO employees_horizontal_partition(
	emp_id, first_name, last_name, department_id, salary)
    VALUES
    ('EMP201', 'Garba', 'Tope', 5, 60000),
    ('EMP202', 'Esther', 'Ola', 8, 70000),
    ('EMP203', 'Shehu', 'Adams', 12, 90000),
    ('EMP204', 'Chidinma', 'Ugo', 18, 100000),
    ('EMP205', 'Eve', 'Adams', 25, 300000),
    ('EMP206', 'Frank', 'Bob', 28, 200000),
    ('EMP207', 'Grace', 'Tall', 35, 90000);
    
## confirm if partition worked
## Add Format=JSON to Explain because the ordinary explain won't show parttion column in output on MariaDB
EXPLAIN FORMAT=JSON
SELECT * 
FROM employees_horizontal_partition 
WHERE department_id = 20;

# Partition based on KEYS
CREATE TABLE employees_key_partition(
	emp_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT NOT NULL,
    salary DECIMAL (10,2),
    PRIMARY KEY (emp_id)
    )
    PARTITION BY KEY(emp_id) 
    PARTITIONS 3;
    
-- Insert records into employees_key_partition
INSERT INTO employees_key_partition(
	emp_id, first_name, last_name, department_id, salary)
    VALUES
    ('EMP201', 'Garba', 'Tope', 5, 60000),
    ('EMP202', 'Esther', 'Ola', 8, 70000),
    ('EMP203', 'Shehu', 'Adams', 12, 90000),
    ('EMP204', 'Chidinma', 'Ugo', 18, 100000),
    ('EMP205', 'Eve', 'Adams', 25, 300000),
    ('EMP206', 'Frank', 'Bob', 28, 200000),
    ('EMP207', 'Grace', 'Tall', 35, 90000);

## confirm if partition worked
EXPLAIN FORMAT=JSON
SELECT * 
FROM employees_key_partition 
WHERE emp_id = 'EMP203'; 

## check data in specific partition table
SELECT *
FROM employees_key_partition PARTITION(p2);

# Partition based on Hash
CREATE TABLE employees_hash_partition(
	emp_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT NOT NULL,
    salary DECIMAL (10,2),
    PRIMARY KEY (emp_id, department_id)
    )
    PARTITION BY HASH(department_id) 
    PARTITIONS 3;
    
-- Insert records into employees_hash_partition
INSERT INTO employees_hash_partition(
	emp_id, first_name, last_name, department_id, salary)
    VALUES
    ('EMP201', 'Garba', 'Tope', 5, 60000),
    ('EMP202', 'Esther', 'Ola', 8, 70000),
    ('EMP203', 'Shehu', 'Adams', 12, 90000),
    ('EMP204', 'Chidinma', 'Ugo', 18, 100000),
    ('EMP205', 'Eve', 'Adams', 25, 300000),
    ('EMP206', 'Frank', 'Bob', 28, 200000),
    ('EMP207', 'Grace', 'Tall', 35, 90000);
    
## confirm if partition worked
EXPLAIN FORMAT=JSON
SELECT * 
FROM employees_hash_partition 
WHERE department_id = 28;  

# Round_Robin Partition
CREATE TABLE employees_round_robin(
	emp_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT NOT NULL,
    salary DECIMAL (10,2),
    PARTITIONID INT GENERATED ALWAYS AS (MOD(department_id, 3)) STORED,
    PRIMARY KEY (emp_id, department_id)
    );
    
-- Insert records into employees_round_robin
INSERT INTO employees_round_robin(
	emp_id, first_name, last_name, department_id, salary)
    VALUES
    ('EMP201', 'Garba', 'Tope', 5, 60000),
    ('EMP202', 'Esther', 'Ola', 8, 70000),
    ('EMP203', 'Shehu', 'Adams', 12, 90000),
    ('EMP204', 'Chidinma', 'Ugo', 18, 100000),
    ('EMP205', 'Eve', 'Adams', 25, 300000),
    ('EMP206', 'Frank', 'Bob', 28, 200000),
    ('EMP207', 'Grace', 'Tall', 35, 90000);
    
## confirm if partition worked
SELECT * 
FROM employees_round_robin
WHERE emp_id = 'EMP207'; 

# Confirm partition distribution
SELECT PARTITIONID, COUNT(*) 
FROM employees_round_robin 
GROUP BY PARTITIONID; 

 /* Vertical partitioning split dataset by columns, for instance, a large dataset of employees details can be split into employee basic details,
payment information, sensitive info, while linking the three tables using thr unique ID. */


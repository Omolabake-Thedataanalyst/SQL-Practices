# Overview
This project contains a comprehensive series of advanced SQL queries spread across two tutorial files (`sql_tutorial.sql` and `SQL tutorial 2.sql`). The scripts are designed to demonstrate a deep understanding of complex relational database operations, data engineering principles, query optimization, and transaction management. This serves as a technical showcase of advanced SQL capabilities using human resources and financial schemas.

## Database Context
The queries are executed across two primary databases, `sql_tutorial` and `hrms`, focusing on a robust organizational and financial structure:

* **employees & departments:** Core tables handling employee details and department mappings.
* **jobs & managers:** Tables defining roles and hierarchical structures.
* **salary_history & department_salary_summary:** Tracking real-time OLTP changes and materialized views.
* **accounts:** A financial table for demonstrating transactional integrity.
* **Partitioned Tables:** Specialized employee tables for demonstrating data partitioning strategies.

# Technical Implementation

## 1. Advanced Joins & Set Operators
Demonstrates the ability to merge disparate tables and handle missing data seamlessly.
* **Inner, Left, Right, and Full Outer Joins:** Handling standard relational linkages and simulating full outer joins using `UNION` in MySQL.
* **Set Operators (Intersect Simulation):** Utilizing `NOT EXISTS` to find non-matching records, mimicking `INTERSECT` for MySQL environments.

```sql
SELECT d.department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.department_id
);
```

## 2. Window Functions & CTEs
Used for complex analytical querying without collapsing rows.
* **Ranking & Navigation:** Utilizing `ROW_NUMBER()`, `RANK()`, `LEAD()`, and `LAG()` to analyze salary trends and compare an employee's performance score to previous/next evaluations.
* **Common Table Expressions (CTE):** Structuring complex queries, like calculating total salaries by department, for better readability and logic flow.

```sql
SELECT e.first_name, e.salary,
    LAG(e.salary) OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS previous_salary,
    LEAD(e.salary) OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS next_salary
FROM employees e;
```

## 3. Data Aggregation & Conditional Logic
* **Conditional Aggregation:** Using `CASE` statements inside `SUM()` to split salary metrics into high and low brackets dynamically.
* **Rollup & Cube Workarounds:** Implementing `WITH ROLLUP` and `UNION ALL` to generate super-aggregate rows and sub-totals for multi-dimensional analysis (e.g., department and performance combinations).

## 4. Query Optimization & Indexing
* **Execution Analysis:** Utilizing `EXPLAIN`, `ANALYZE`, and `PROFILING` to understand query execution plans, measure exact execution times, and optimize performance.
* **Indexing:** Creating primary and secondary indexes (`CREATE INDEX`) to dramatically speed up retrieval times for frequently queried columns.

## 5. Triggers & OLTP (Online Transactional Processing)
* **Real-time Auditing:** Implementing an `AFTER UPDATE` trigger to automatically log salary changes into a `salary_history` table, ensuring strict data governance and history tracking.

```sql
CREATE TRIGGER after_salary_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN 
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO salary_history(emp_id, old_salary, new_salary, change_date)
        VALUES (NEW.emp_id, Old.salary, NEW.salary, NOW());
    END IF;
END $$
```

## 6. Views, Materialized Views & Stored Procedures
* **Dynamic & Materialized Views:** Creating a standard `VIEW` for quick employee details, and implementing a simulated Materialized View using a separate summary table refreshed via a Stored Procedure.
* **Stored Procedures:** Writing reusable procedures with `IN` parameters to handle dynamic data retrieval, such as filtering employees by hire dates or retrieving details by ID.

## 7. ACID Transactions & Error Handling
* **Financial Integrity:** Writing a robust money transfer procedure that utilizes `START TRANSACTION`, `COMMIT`, and `ROLLBACK` to ensure ACID compliance during account balance transfers.
* **Error Handling:** Using `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION` to gracefully catch and handle runtime errors (e.g., division by zero).

## 8. Data Partitioning Strategies
Splitting massive datasets to enhance query performance and maintainability.
* **Horizontal Partitioning:** Implementing `RANGE`, `KEY`, `HASH`, and `Round-Robin` partitioning strategies to distribute employee data optimally across storage layers.

# Skills Demonstrated
**Complex Analytical Thinking:** Utilizing Window Functions and CTEs to perform deep-dive data analysis efficiently.

**Data Engineering & ETL:** Extracting, transforming (handling NULLs and anomalies), and loading data into finalized operational schemas.

**Database Administration (DBA):** Implementing partitioning, query profiling, and indexing to ensure databases scale effectively under heavy load.

**Data Integrity & Security:** Enforcing ACID properties using explicit transaction control and automating audit trails with triggers.

**Syntactic Adaptability:** Developing workarounds for missing features in MySQL (e.g., Full Outer Joins, Intersect, Cube).

# **Why This Matters**
For a business, mastering these advanced SQL concepts is the bridge between basic data retrieval and building highly scalable, performant data systems. Whether it's ensuring financial transactions don't fail silently, tracking historical changes for compliance, or optimizing queries that scan millions of rows, these techniques form the backbone of modern enterprise data architecture and accurate business intelligence.

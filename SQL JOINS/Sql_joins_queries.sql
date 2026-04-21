-- Identifying the database to query
USE enoch;

-- Trying few join types
-- By joining the list of products from the 'tbl_product table' (first/left table) 
-- and product colour Id from the 'tbl_product_color table' (second/right table)

-- Inner Join
SELECT p.p_id, p.p_name, c.color_id
FROM tbl_product p 
INNER JOIN tbl_product_color c 
ON p.p_id = c.p_id;

-- The Inner join returns the matching records from the two tables

-- Left Join
SELECT p.p_id, p.p_name, c.color_id
FROM tbl_product p 
LEFT JOIN tbl_product_color c 
ON p.p_id = c.p_id;

-- The Left Join returns all records from the left table (first table) 
and the matching records from the right table (second table). If there is no match, the result is NULL on the right side.

-- Right Join
SELECT p.p_id, p.p_name, c.color_id
FROM tbl_product p 
RIGHT JOIN tbl_product_color c 
ON p.p_id = c.p_id;

 -- The Right Join returns all records from the right table (second table) and 
 -- the matching records from the left table (first table). If there is no match, the result is NULL on the left side.

-- Cross Join
SELECT p.p_id, p.p_name, c.color_id
FROM tbl_product p 
CROSS JOIN tbl_product_color c 
ON p.p_id = c.p_id;

-- The Cross Join returns every possible combination of records from the two tables.

-- Full outer join
-- Using the union of left and right join because my database is not supporting full outer join syntax
SELECT p.p_id, p.p_name, c.color_id
FROM tbl_product p 
LEFT JOIN tbl_product_color c 
ON p.p_id = c.p_id

UNION

SELECT p.p_id, p.p_name, c.color_id
FROM tbl_product p 
RIGHT JOIN tbl_product_color c 
ON p.p_id = c.p_id;

-- The full outer Join (the union of left and right join) returns 
-- all matching and unmatching records from both tables making it easy to detect null values
# 📌 Overview
This contains a series of SQL queries designed to demonstrate a deep understanding of relational database operations, specifically focusing on Joins. The ability to merge disparate tables is a fundamental skill for any data professional, and this project serves as a technical showcase of those capabilities using a product database schema.

## 🗄️ Database Context
The queries are executed within the enoch database, focusing on two primary tables:

* tbl_product: Containing core product identifiers and names.
* tbl_product_color: Containing color mappings and product associations.

# 🛠️ Technical Implementation
1. **Inner Join**
Used to retrieve only the records that have matching values in both tables.

```sql
SELECT p.p_id, p.p_name, c.color_id
FROM tbl_product p 
INNER JOIN tbl_product_color c ON p.p_id = c.p_id;
```

2. **Left & Right Outer Joins**
These queries demonstrate the ability to preserve data from a "primary" table while looking for matches in the secondary table.

**Left Join:** Ensures all products are listed, even if they lack a color assignment.

**Right Join:** Ensures all recorded colors are listed, even if no product is currently associated with them.

3. **Full Outer Join (Syntax Workaround)**
Since many SQL dialects (including the one used here) do not natively support the FULL OUTER JOIN syntax, I implemented a manual UNION of a Left and Right Join.

**Analyst Insight:** This approach ensures a complete view of the data landscape, making it easy to detect NULL values and data orphans on either side of the relationship.

```sql
SELECT p.p_id, p.p_name, c.color_id FROM tbl_product p 
LEFT JOIN tbl_product_color c ON p.p_id = c.p_id
UNION
SELECT p.p_id, p.p_name, c.color_id FROM tbl_product p 
RIGHT JOIN tbl_product_color c ON p.p_id = c.p_id;
```
4. **Cross Join**
Used to create a Cartesian product, returning every possible combination of products and colors.

```sql
SELECT p.p_id, p.p_name, c.color_id
FROM tbl_product p 
CROSS JOIN tbl_product_color c ON p.p_id = c.p_id;
```
## 🧠 Skills Demonstrated
**Relational Logic:** Understanding how keys (p_id) link data across a schema.

**Data Integrity:** Using Joins to identify missing records or NULL values.

**Syntactic Adaptability:** Implementing a UNION workaround for environments that lack specific join support.

**Query Optimization:** Using aliases (p, c) for cleaner, more readable code.

**🚀 Why This Matters**
For a business, understanding Joins is the difference between seeing a "full picture" and missing critical data. Whether it's identifying which products have no stock or which customers haven't made a purchase, these SQL foundations are the building blocks of accurate business intelligence.

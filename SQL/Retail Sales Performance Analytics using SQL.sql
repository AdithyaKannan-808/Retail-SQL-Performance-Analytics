CREATE DATABASE retail_sql_project;
USE retail_sql_project;
CREATE TABLE IF NOT EXISTS fact_sales (
  order_id        BIGINT,
  order_dt        DATE,
  seller_name     VARCHAR(100),
  customer_name   VARCHAR(120),
  product_name    VARCHAR(160),
  category        VARCHAR(60),
  region          VARCHAR(60),
  qty             INT,
  unit_price      DECIMAL(10,2),
  discount_pct    DECIMAL(5,2),
  profit          DECIMAL(12,2)
);
DESC fact_sales;

 USE retail_sql_project;
 SELECT database();
 CREATE TABLE people (
 Person VARCHAR(60),
 Region VARCHAR(10)
 );
 DESC people;
 CREATE  TABLE returned(
 Returned VARCHAR(10),
 Order_ID BIGINT );
 DESC returned;
ALTER TABLE returned MODIFY Order_ID VARCHAR(30);
SELECT Order_ID FROM returned;
DROP TABLE fact_sales;
USE retail_sql_project;

CREATE TABLE orders (
  row_id INT,
  order_id VARCHAR(30),
  order_date DATE,
  ship_date DATE,
  ship_mode VARCHAR(50),
  customer_id VARCHAR(30),
  customer_name VARCHAR(120),
  segment VARCHAR(50),
  city VARCHAR(60),
  state VARCHAR(60),
  region VARCHAR(60),
  postal_code VARCHAR(20),
  product_id VARCHAR(40),
  category VARCHAR(60),
  sub_category VARCHAR(60),
  product_name VARCHAR(220),
  sales DECIMAL(12,2),
  quantity INT,
  discount DECIMAL(5,2),
  profit DECIMAL(12,2),
  returns VARCHAR(10),
  sales_person VARCHAR(120)
);
DESC Orders;
TRUNCATE TABLE returned;
CREATE TABLE Returned(
Returned VARCHAR(5),
Order_ID VARCHAR(30) );
DESC Returned;
SELECT * FROM Returned LIMIT 5;
USE retail_sql_project;

DROP VIEW IF EXISTS vw_orders_full;

CREATE VIEW vw_orders_full AS
SELECT
  o.row_id,
  o.order_id,
  o.order_date,
  o.ship_date,
  o.ship_mode,
  o.customer_id,
  o.customer_name,
  o.segment,
  o.city,
  o.state,
  o.region,
  o.postal_code,
  o.product_id,
  o.category,
  o.sub_category,
  o.product_name,
  o.sales,
  o.quantity,
  o.discount,
  o.profit,
  o.sales_person,
  -- unify return flag: either orders.returns says Yes, or it exists in Returned table
  CASE
    WHEN r.Order_ID IS NOT NULL THEN 1
    WHEN LOWER(TRIM(o.returns)) IN ('yes','y','returned','true','1') THEN 1
    ELSE 0
  END AS is_returned,
  -- bring in salesperson region from people, if it exists
  p.Region AS sales_person_region
FROM orders o
LEFT JOIN Returned r
  ON r.Order_ID = o.order_id
LEFT JOIN people p
  ON p.Person = o.sales_person;
SELECT * FROM vw_orders_full LIMIT 5;
DROP VIEW IF EXISTS vw_monthly_actuals;
CREATE VIEW vw_monthly_actuals AS
SELECT
  UPPER(TRIM(sales_person))           AS sales_person,
  DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
  DATE_FORMAT(order_date, '%Y-%m')    AS month_yyyymm,
  ROUND(SUM(sales),  2)               AS revenue_actual,
  ROUND(SUM(profit), 2)               AS profit_actual
FROM vw_orders_full
GROUP BY UPPER(TRIM(sales_person)),
         DATE_FORMAT(order_date, '%Y-%m-01'),
         DATE_FORMAT(order_date, '%Y-%m');
CREATE TABLE IF NOT EXISTS sales_target_monthly (
  sales_person   VARCHAR(120) NOT NULL,
  month_yyyymm   CHAR(7)      NOT NULL,
  revenue_target DECIMAL(12,2) NOT NULL,
  profit_target  DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (sales_person, month_yyyymm)
);

TRUNCATE TABLE sales_target_monthly;
INSERT INTO sales_target_monthly
  (sales_person, month_yyyymm, revenue_target, profit_target)
SELECT
  s.sales_person,
  s.month_yyyymm_next,
  ROUND(SUM(s.revenue_actual) * 1.03, 2) AS revenue_target,
  ROUND(SUM(s.profit_actual)  * 1.03, 2) AS profit_target
FROM (
  SELECT
    m.sales_person,                               -- already UPPER(TRIM(...)) in vw_monthly_actuals
    DATE_FORMAT(DATE_ADD(m.month_start, INTERVAL 1 MONTH), '%Y-%m') AS month_yyyymm_next,
    m.revenue_actual,
    m.profit_actual
  FROM vw_monthly_actuals m
) AS s
GROUP BY s.sales_person, s.month_yyyymm_next;     -- <-- collapses any dupes for the same key
SELECT sales_person, month_yyyymm, COUNT(*) AS rows_same_key
FROM sales_target_monthly
GROUP BY sales_person, month_yyyymm
HAVING COUNT(*) > 1;




SELECT COUNT(*) AS Row_count, MIN(order_date) AS Start_date, MAX(order_date) AS End_date FROM vw_orders_full ;
SELECT 
 ROUND(SUM(sales),2) AS Total_sales,
 ROUND(SUM(profit),2) AS Total_profit,
 ROUND(avg(discount),2) AS Avg_discount,
 ROUND(SUM(is_returned)/COUNT(*)*100,2) AS return_rate_pct
 FROM vw_orders_full;
 SELECT 
  DATE_FORMAT(order_date, '%Y-%m') AS month,
  ROUND(SUM(sales),2)  AS sales,
  ROUND(SUM(profit),2) AS profit,
  ROUND(SUM(CASE WHEN is_returned=1 THEN sales ELSE 0 END),2) AS returned_sales
FROM vw_orders_full
GROUP BY month
ORDER BY month;
SELECT 
 category, COUNT(*) AS orders,
 SUM(is_returned) AS returned_orders,
  ROUND(SUM(is_returned)/COUNT(*)*100,2) AS return_rate_pct
FROM vw_orders_full
GROUP BY category
ORDER BY return_rate_pct DESC;
SELECT 
 sales_person,
 ROUND(SUM(profit),2) AS total_profit,
 ROUND(SUM(sales),2) AS total_sales,
 COUNT(DISTINCT order_id) AS orders
 FROM vw_orders_full
 GROUP BY sales_person
 ORDER BY total_profit DESC;
 
 USE retail_sql_project;
 
 /*CREATE TABLE sales_target_monthly (
 sales_person VARCHAR(120) NOT NULL,
 month_yyyymm CHAR(7) NOT NULL,
 revenue_target decimal(12,2) NOT NULL,
 profit_target DECIMAL (12,2) NOT NULL,
 PRIMARY KEY (sales_person, month_yyyymm) );
 DESC sales_target_monthly;
 USE retail_sql_project;
 INSERT INTO retail_sql_project.sales_target_monthly
  (sales_person, month_yyyymm, revenue_target, profit_target)
SELECT 
  v.sales_person,
  DATE_FORMAT(v.order_date, '%Y-%m') AS month_yyyymm,
  ROUND(SUM(v.sales)  * 1.10, 2)     AS revenue_target,
  ROUND(SUM(v.profit) * 1.10, 2)     AS profit_target
FROM retail_sql_project.vw_orders_full AS v
GROUP BY v.sales_person, DATE_FORMAT(v.order_date, '%Y-%m');

SELECT 
    sales_person,
    SUM(revenue_target) AS total_target
FROM sales_target_monthly
GROUP BY sales_person
ORDER BY total_target DESC;
USE retail_sql_project;

-- (Only if the table might not exist)
/*CREATE TABLE IF NOT EXISTS sales_target_monthly (
  sales_person   VARCHAR(120) NOT NULL,
  month_yyyymm   CHAR(7)      NOT NULL,   -- 'YYYY-MM'
  revenue_target DECIMAL(12,2) NOT NULL,
  profit_target  DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (sales_person, month_yyyymm)
);

USE retail_sql_project;

-- sanity: table really empty?
SELECT COUNT(*) AS before_rows FROM sales_target_monthly;

TRUNCATE TABLE sales_target_monthly;

-- normalized insert (+3%)
INSERT INTO sales_target_monthly (sales_person, month_yyyymm, revenue_target, profit_target)
SELECT 
  -- canonicalize names to avoid duplicates from spaces/case
  UPPER(TRIM(sales_person))  AS sales_person,
  DATE_FORMAT(order_date, '%Y-%m') AS month_yyyymm,
  ROUND(SUM(sales)  * 1.03, 2) AS revenue_target,
  ROUND(SUM(profit) * 1.03, 2) AS profit_target
FROM vw_orders_full
GROUP BY UPPER(TRIM(sales_person)), DATE_FORMAT(order_date, '%Y-%m');

-- verify
SELECT COUNT(*) AS after_rows FROM sales_target_monthly;
SELECT * FROM sales_target_monthly ORDER BY sales_person, month_yyyymm LIMIT 10; */
-- Quick sanity (optional)
SELECT COUNT(*) FROM sales_target_monthly;

-- Final hero query
WITH actuals AS (
  SELECT
    UPPER(TRIM(sales_person))           AS sales_person,
    DATE_FORMAT(order_date, '%Y-%m')    AS month_yyyymm,
    ROUND(SUM(sales),  2)               AS revenue_actual,
    ROUND(SUM(profit), 2)               AS profit_actual
  FROM vw_orders_full
  GROUP BY UPPER(TRIM(sales_person)), DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
  a.month_yyyymm,
  a.sales_person,
  a.revenue_actual,
  t.revenue_target,
  ROUND((a.revenue_actual - t.revenue_target) / NULLIF(t.revenue_target,0) * 100, 2) AS revenue_var_pct,
  a.profit_actual,
  t.profit_target,
  ROUND((a.profit_actual - t.profit_target) / NULLIF(t.profit_target,0) * 100, 2) AS profit_var_pct,
  CASE
    WHEN (a.profit_actual - t.profit_target) / NULLIF(t.profit_target,0) * 100 >= 2  THEN 'Overachiever'
    WHEN (a.profit_actual - t.profit_target) / NULLIF(t.profit_target,0) * 100 > -2 THEN 'On target'
    ELSE 'Underperformer'
  END AS performance_status,
  RANK() OVER (PARTITION BY a.month_yyyymm ORDER BY a.profit_actual DESC) AS monthly_rank
FROM actuals a
JOIN sales_target_monthly t        -- ensure this name matches your table
  ON t.sales_person  = a.sales_person
 AND t.month_yyyymm  = a.month_yyyymm
ORDER BY a.month_yyyymm, monthly_rank DESC
LIMIT 4;
DROP VIEW IF EXISTS vw_target_attainment;
CREATE VIEW vw_target_attainment AS
WITH actuals AS (
  SELECT
    UPPER(TRIM(sales_person)) AS sales_person,
    DATE_FORMAT(order_date, '%Y-%m') AS month_yyyymm,
    ROUND(SUM(sales), 2)  AS revenue_actual,
    ROUND(SUM(profit), 2) AS profit_actual
  FROM vw_orders_full
  GROUP BY UPPER(TRIM(sales_person)), DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
  a.month_yyyymm, a.sales_person,
  a.revenue_actual, t.revenue_target,
  ROUND((a.revenue_actual - t.revenue_target)/NULLIF(t.revenue_target,0)*100,2) AS revenue_var_pct,
  a.profit_actual,  t.profit_target,
  ROUND((a.profit_actual  - t.profit_target)/NULLIF(t.profit_target,0)*100,2)   AS profit_var_pct,
  CASE
    WHEN (a.profit_actual - t.profit_target)/NULLIF(t.profit_target,0)*100 >= 2  THEN 'Overachiever'
    WHEN (a.profit_actual - t.profit_target)/NULLIF(t.profit_target,0)*100 > -2 THEN 'On target'
    ELSE 'Underperformer'
  END AS performance_status,
  RANK() OVER (PARTITION BY a.month_yyyymm ORDER BY a.profit_actual DESC) AS monthly_rank
FROM actuals a
JOIN sales_target_monthly t
  ON t.sales_person = a.sales_person
 AND t.month_yyyymm = a.month_yyyymm;
SELECT *
FROM vw_target_attainment
WHERE performance_status = 'Overachiever'
ORDER BY month_yyyymm, monthly_rank
LIMIT 4;
SELECT month_yyyymm, sales_person, profit_var_pct
FROM vw_target_attainment
WHERE profit_var_pct <= -10
ORDER BY month_yyyymm, profit_var_pct;
SELECT
  month_yyyymm,
  COUNT(*)                                     AS salespeople,
  SUM(profit_actual)                           AS team_profit,
  ROUND(AVG(profit_var_pct),2)                 AS avg_profit_var_pct,
  SUM(performance_status='Overachiever')       AS overachievers,
  SUM(performance_status='On target')          AS on_target,
  SUM(performance_status='Underperformer')     AS underperformers
FROM vw_target_attainment
GROUP BY month_yyyymm
ORDER BY month_yyyymm;
-- Report Screenshots
DESC vw_orders_full;
SHOW FULL TABLES FROM retail_sql_project;
SELECT * FROM vw_orders_full LIMIT 5;
SELECT sales_person, month_yyyymm, revenue_actual, profit_actual 
FROM vw_monthly_actuals 
LIMIT 5;
SELECT * FROM sales_target_monthly 
ORDER BY  month_yyyymm 
LIMIT 4;
SELECT month_yyyymm, sales_person, revenue_actual, revenue_target,
       profit_actual, profit_target, profit_var_pct, performance_status, monthly_rank
FROM vw_target_attainment
ORDER BY month_yyyymm, monthly_rank
LIMIT 4;
SELECT 
  ROUND(SUM(sales),2) AS total_sales,
  ROUND(SUM(profit),2) AS total_profit,
  ROUND(SUM(is_returned)/COUNT(*)*100,2) AS return_rate_pct
FROM vw_orders_full;
SELECT 
  DATE_FORMAT(order_date, '%Y-%m') AS month,
  ROUND(SUM(sales),2)  AS sales,
  ROUND(SUM(profit),2) AS profit
FROM vw_orders_full
GROUP BY month
ORDER BY month;










 
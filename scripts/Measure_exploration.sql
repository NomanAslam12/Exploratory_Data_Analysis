USE DataWarehouse
-- Total Sales
SELECT sum(sales_amount) AS total_sales FROM gold.fact_sales;
-- 29356250

-- Find how many items are sold
SELECT sum(quantity) AS total_quantity FROM gold.fact_sales;
-- 60423

-- Find average selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales;
--486

--Find the total number of Orders
SELECT COUNT(order_number) AS total_orders from gold.fact_sales; --60398
SELECT COUNT(DISTINCT order_number) AS total_orders from gold.fact_sales; --27659

--Find the total number of products
SELECT COUNT(product_key) FROM gold.dim_products;
SELECT COUNT(distinct product_key) FROM gold.dim_products;
--295

--Find the total number of customers
SELECT COUNT(customer_id) FROM gold.dim_customers;
SELECT COUNT(DISTINCT customer_id) FROM gold.dim_customers;
--18484

--Find the total number of customers that placed the order
SELECT COUNT(DISTINCT customer_key) FROM gold.fact_sales;


-- Geenrate a Report of all key metrics of the business
SELECT 'Total Sales' AS measure, sum(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity Sold' AS measure,sum(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Product Price' AS measure,AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure,COUNT(DISTINCT order_number) AS measure_value from gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure, COUNT(distinct product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT  'Total Customers' AS measure,COUNT(DISTINCT customer_id) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT  'Total Customers that placed orders' AS measure,COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales



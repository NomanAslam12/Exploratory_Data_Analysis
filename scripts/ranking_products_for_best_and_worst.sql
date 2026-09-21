-- which 5 products generate the highest revenue
select TOP 5
p.product_name,
sum(sales_amount) total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC

SELECT * FROM(
select 
p.product_name,
sum(s.sales_amount) AS total_sales,
rank() OVER( ORDER BY sum(sales_amount) DESC) as ranked_products
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.product_name
)t 
WHERE ranked_products <= 5


-- which 5 products generate the lowest revenue
select TOP 5
p.product_name,
sum(sales_amount) total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales ASC


-- which top 10 customers have generated the highest revenue
select TOP 10
c.customer_key,
c.first_name,
c.last_name,
count(DIsTINCT order_number) AS orders_placed,
sum(sales_amount) total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key = c.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
ORDER BY total_sales DESC


SELECT * FROM gold.fact_sales;
SELECT * FROM gold.dim_customers

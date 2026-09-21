SELECT
FORMAT(order_date, 'yyyy-MMM') AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(distinct customer_key) AS cusotmers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP  BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')
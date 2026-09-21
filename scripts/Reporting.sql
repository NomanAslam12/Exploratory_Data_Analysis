/* Group customers into three segments based on their data spending behaviour:
	- VIP: customer with atleast 12 months of history and spending morethan $5000.
	- Regular: Customers with atleast 12 months of history but spending $5000 or less.
	- New: Customer with a lifespan less than 12 months.
And find the total number of customers each group */



WITH customer_spending AS(
SELECT
	c.customer_key,
	SUM(f.sales_amount) AS total_spending,
	MIN(f.order_date) AS first_order,
	MAX(f.order_date) AS last_order,
	DATEDIFF(month, MIN(order_date),MAX(order_date)) AS life_span
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT 
	cst_segment,
	COUNT(customer_key)
FROM(
	SELECT
	customer_key,
	CASE
		WHEN life_span >= 12 and total_spending >= 5000 THEN 'VIP'
		WHEN life_span >= 12 and total_spending < 5000 THEN 'Regular'
		ELSE 'NEW'
		END cst_segment
	FROM customer_spending)t
GROUP BY cst_segment

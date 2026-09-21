
/*
======================================================================
Product Report
=====================================================================
Purpose:
	- This report consolidates key products metrics and behaviour
*/

CREATE VIEW gold.report_products AS



/*----------------------------------------------------------------------
1) Base Query : Retrieve necessary columns from tables
----------------------------------------------------------------------*/

WITH base_query AS (
	SELECT
	f.order_number,
	f.product_key,
	f.customer_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
	),
product_aggregation AS (
/*------------------------------------------------------
2) Product Aggregations : Summarize key metrics at the customer level
--------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_customers,
	MAX(order_date) AS last_sale_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS life_span,
	ROUND(AVG(CAST(sales_amount AS float) / quantity),1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
/*------------------------------------------------------
3) Final Query : Combining all metrics into one output
--------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE 
		WHEN total_sales > 50000 THEN 'High_performer'
		WHEN total_sales >= 10000 THEN 'Mid_range'
		ELSE 'Low_Performer'
	END AS product_segment,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	life_span,
	avg_selling_price,
	-- Average Order Revenue
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Compute average monthly spend
	CASE 
		WHEN life_span = 0 THEN total_sales
		ELSE total_sales / life_span
	END AS avg_monthly_revenue
FROM product_aggregation
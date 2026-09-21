-- Which product category contribute the most to overall sales

WITH all_sales As (
		SELECT 
		p.category category,
		sum(sales_amount) total_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p ON p.product_key = s.product_key
	WHERE order_date IS NOT NULL
	GROUP BY   p.category )
select	
category,
total_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER())*100,2),' %') AS pct_total_sales
FROM all_sales
order by total_sales DESC
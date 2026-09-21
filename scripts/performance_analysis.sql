/* Analyze the yearly performance of products by comparing thier sales
to both the average sales performance of the product and the preivous year's sales*/

WITH yearly_product_sales AS(
	SELECT 
		DATETRUNC(year,order_date) year,
		p.product_name product,
		sum(sales_amount) current_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p ON p.product_key = s.product_key
	WHERE order_date IS NOT NULL
	GROUP BY  DATETRUNC(year,order_date), p.product_name
	)
SELECT 
year,
product,
current_sales,
AVG(current_sales) OVER(PARTITION BY product ) avg_sales ,
current_sales - AVG(current_sales) OVER(PARTITION BY product ) difference_avg,
CASE 
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product ) > 0 THEN 'Above Avg'
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product ) < 0 THEN 'Below Avg'
	ELSE 'Average'
	END avg_change,
--Year Over Year (YoY) Change
lag(current_sales) OVER (partition by product order by year) py_sales,
current_sales - lag(current_sales) OVER (partition by product order by year) as diff_py,
CASE 
	WHEN current_sales - lag(current_sales) OVER (partition by product order by year) > 0 THEN 'Increasing sales'
	WHEN current_sales - lag(current_sales) OVER (partition by product order by year) < 0 THEN 'Decreasing sales'
	ELSE 'No change'
	END py_change
FROM yearly_product_sales
ORDER BY product, year





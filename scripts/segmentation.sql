/* Segment products into cost ranges and count how many products fall into each segment */

with product_segment as (
	SELECT 
	product_key,
	product_name,
	cost,
	CASE 
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'above_1000'
		END AS cost_range
	FROM
	gold.dim_products
)
SELECT
cost_range,
count(product_key) as products_quantity
FROM product_segment
Group by cost_range 
ORDER BY products_quantity DESC




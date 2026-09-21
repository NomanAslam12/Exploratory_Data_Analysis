
SELECT 
*,
SUM(total_sales) OVER(partition by order_year order by order_month) AS running_total_sales,
AVG(avg_sales) OVER(partition by order_year order by order_month) AS moving_avg_sales
FROM
(SELECT 
DATETRUNC(year, order_date) as order_year,
DATETRUNC(month, order_date) as order_month,
sum(sales_amount) AS total_sales,
AVG(sales_amount) AS avg_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date), DATETRUNC(month, order_date) 
)t

-- check for the partition by difference
SELECT 
    *,
    SUM(total_sales) OVER(PARTITION BY order_year ORDER BY order_month) AS correct_running,
    SUM(total_sales) OVER(PARTITION BY order_month ORDER BY order_month) AS broken_running
FROM (SELECT 
DATETRUNC(year, order_date) as order_year,
DATETRUNC(month, order_date) as order_month,
sum(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date), DATETRUNC(month, order_date) ) t


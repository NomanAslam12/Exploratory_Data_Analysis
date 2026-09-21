-- First and Last date available

select 
max(order_date) AS first_order_date,
min(order_date) AS max_order_date,
DATEDIFF(YEAR,min(order_date),max(order_date)) 
from gold.fact_sales

-- youngest and oldest customer

select 
max(birthdate) youngest_customer,
DATEDIFF(YEAR,max(birthdate),GETDATE()),
min(birthdate) oldest_customer,
DATEDIFF(YEAR,min(birthdate),GETDATE())
FROM gold.dim_customers

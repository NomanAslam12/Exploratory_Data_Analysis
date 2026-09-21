# SQL Exploratory Data Analysis: Sales Data Warehouse
 
An exploratory analysis of a sales data warehouse in T-SQL (SQL Server). The scripts start with basic profiling of the tables, move through time-series, ranking and segmentation queries, and finish with two reporting views that package customer and product metrics for BI tools.
 
I built this by following the SQL course project from Data with Baraa, and wrote and ran the queries myself against the `DataWarehouse` database. That database comes from my earlier project, [sql-data-warehouse-project](https://github.com/NomanAslam12/sql-data-warehouse-project), where I built the Bronze, Silver and Gold layers from CRM and ERP CSV exports. This repo is the analysis that sits on top of its Gold views.
 
## Data model
 
The queries run against three tables in the `gold` schema, arranged as a star schema.
 
| Table | Grain | Columns used |
|---|---|---|
| `gold.fact_sales` | One row per order line | `order_number`, `product_key`, `customer_key`, `order_date`, `sales_amount`, `quantity`, `price` |
| `gold.dim_customers` | One row per customer | `customer_key`, `customer_id`, `customer_number`, `first_name`, `last_name`, `country`, `gender`, `birthdate` |
| `gold.dim_products` | One row per product | `product_key`, `product_id`, `product_name`, `category`, `subcategory`, `cost` |
 
## Headline numbers
 
Taken from `Measure_exploration.sql`:
 
| Measure | Value |
|---|---|
| Total sales | 29,356,250 |
| Units sold | 60,423 |
| Average unit price | 486 |
| Order lines | 60,398 |
| Distinct orders | 27,659 |
| Products | 295 |
| Customers in `dim_customers` | 18,484 |
 
The gap between order lines (60,398) and distinct orders (27,659) is why order counts in this project use `COUNT(DISTINCT order_number)` and not `COUNT(*)`.
 
## Findings
 
The figures below come from `findings.sql`. That script filters out rows with no `order_date`. Two orders have no date, worth 4,992 in sales, so the totals here add up to 29,351,258 and not the 29,356,250 in the headline table.
 
### Time span and growth
 
Orders run from 29 December 2010 to 28 January 2014. Only 2011, 2012 and 2013 are complete years. 2010 has 14 orders from its last days, and 2014 has 871 orders from January, so their year-over-year percentages (+16,194.9% and -99.7%) come from partial periods and mean nothing.
 
| Year | Sales | Orders | Customers who ordered | Average order value |
|---|---|---|---|---|
| 2011 | 7,075,088 | 2,216 | 2,216 | 3,193 |
| 2012 | 5,842,231 | 3,269 | 3,255 | 1,787 |
| 2013 | 16,344,878 | 21,287 | 17,427 | 768 |
 
Sales fell 17.4% in 2012 and rose 179.8% in 2013. Bikes drove the 2013 increase: bike revenue went from 5,839,443 to 15,353,707 (+162.9%), which is 9,514,264 of the 10,502,647 total increase (90.6%). Accessories and clothing added the other 991,171. The average order value fell because the order mix changed. In 2011 and 2012 almost every order was a single bike (2,216 orders and 2,216 bikes in 2011), while in 2013 accessories and clothing made up 43,103 of the 52,807 units sold (81.6%). Revenue per bike also fell each year, from 3,193 in 2011 to 1,786 in 2012 and 1,582 in 2013. I have not checked whether that comes from a shift toward cheaper models or from price changes.
 
The three best months are December, November and October 2013 (1,874,128, 1,780,688 and 1,673,261). With three full years and growth this steep, the data cannot separate seasonality from the trend. The weakest full month is May 2012, at 358,866.
 
### Categories and products
 
Bikes bring in 96.46% of revenue (28,311,657) but only 25.17% of units sold. Accessories are 59.76% of units and 2.38% of revenue (699,909). Clothing is 15.07% of units and 1.16% of revenue (339,692).
 
Those shares cover a period in which the categories were not all on sale. Nothing but bikes sold in 2010 and 2011. In 2012 there were 106 accessory units (2,146 in sales) and 22 clothing units (642). Only 2013 has all three categories at scale, and there bikes were 93.94% of revenue, accessories 4.08% and clothing 1.98%. January 2014 has no bike sales at all: its 45,642 comes from accessories (30,332) and clothing (15,310). The data does not show whether bikes stopped selling or the extract is incomplete, so January 2014 is not comparable with earlier months.
 
The five best-selling products are all Mountain-200 variants, each between 4.40% and 4.68% of sales, and together 6,667,244 or 22.7% of revenue. The five lowest are accessories and clothing, all under 0.03% of sales each: Touring Tire Tube (7,435), Bike Wash - Dissolver (7,272), Patch Kit/8 Patches (6,378), Racing Socks- M (2,682) and Racing Socks- L (2,430). Products here are colour and size variants, so one model line can fill several ranking slots.
 
### Customers
 
27,657 orders came from 18,482 customers: an average order value of 1,061.26, 1.50 orders per customer and 2.18 lines per order.
 
Revenue is concentrated. The top 10% of customers (1,849) account for 40.28% of sales, the top 20% for 66.41%, and the bottom 50% together for 1.94%.
 
| Segment | Customers | Share of customers | Sales | Share of sales |
|---|---|---|---|---|
| New | 14,629 | 79.15% | 11,086,797 | 37.77% |
| VIP | 1,653 | 8.94% | 10,760,470 | 36.66% |
| Regular | 2,200 | 11.90% | 7,503,991 | 25.57% |
 
New is the largest segment because 17,427 customers ordered in 2013, and the data ends in January 2014. Most customers had less than 12 months of history by construction, so the label reflects tenure inside the data window and not low value. New customers generate more revenue than VIP customers.
 
### Countries
 
| Country | Customers | Orders | Sales | Share of sales |
|---|---|---|---|---|
| United States | 7,481 | 9,229 | 9,162,225 | 31.22% |
| Australia | 3,591 | 6,718 | 9,060,145 | 30.87% |
| United Kingdom | 1,913 | 3,031 | 3,389,046 | 11.55% |
| Germany | 1,780 | 2,484 | 2,894,066 | 9.86% |
| France | 1,809 | 2,483 | 2,641,223 | 9.00% |
| Canada | 1,571 | 3,375 | 1,977,733 | 6.74% |
| n/a | 337 | 337 | 226,820 | 0.77% |
 
Australia matches the United States in revenue with less than half the customers: 2,523 sales per customer against 1,225. 337 customers have no country in `dim_customers`.
 
## Scripts
 
The files follow the order of a typical EDA: profile the data, look at it over time, compare parts, rank, segment, then report.
 
| File | What it answers |
|---|---|
| `Exploratory_date_analysis.sql` | Date range of orders, youngest and oldest customer |
| `Measure_exploration.sql` | Core business measures, plus a one-query summary report built with `UNION ALL` |
| `magnitude_distribution.sql` | Customers by country and gender, products and average cost by category, revenue and quantity by category, revenue per customer, sales by country |
| `change_over_time.sql` | Monthly sales, distinct customers and quantity |
| `cumulative_analysis.sql` | Running total of sales and a running average, reset each year; includes a check showing what happens when the window is partitioned by month instead of year |
| `performance_analysis.sql` | Yearly sales per product compared with the product's own average and with the previous year (`AVG() OVER`, `LAG()`) |
| `part_to_whole.sql` | Each category's share of total sales |
| `ranking_products_for_best_and_worst.sql` | Top and bottom 5 products by revenue, top 10 customers by revenue; written twice for the top 5, once with `TOP` and once with `RANK()` |
| `segmentation.sql` | Products bucketed into cost ranges, with a count per bucket |
| `Reporting.sql` | Customers split into VIP, Regular and New, with a count per segment |
| `final_customer_report_view.sql` | Creates `gold.report_customers` |
| `final_product_report_view.sql` | Creates `gold.report_products` |
| `findings.sql` | Produces the figures in the Findings section above |
 
## Reporting views
 
Both views are built the same way: a base query joins the fact table to a dimension, a second CTE aggregates to one row per entity, and the final select adds segments and derived metrics.
 
`gold.report_customers` returns one row per customer with age and age group, total orders, sales, quantity, distinct products, lifespan in months, recency, average order value and average monthly spend. Customers are labelled VIP (lifespan of at least 12 months and sales above 5,000), Regular (at least 12 months and sales of 5,000 or less) or New (under 12 months).
 
`gold.report_products` returns one row per product with category, subcategory, cost, orders, sales, quantity, distinct customers, lifespan, average selling price, average order revenue and average monthly revenue. Products are labelled High_performer (sales above 50,000), Mid_range (10,000 to 50,000) or Low_Performer (under 10,000).
 
## SQL techniques used
 
Aggregates with `GROUP BY`, `LEFT JOIN`, CTEs, subqueries, `CASE` segmentation, window functions (`SUM`, `AVG`, `RANK`, `LAG` with `OVER`), date functions (`DATETRUNC`, `DATEDIFF`, `FORMAT`), `UNION ALL`, and `CREATE VIEW`.
 
## Running it
 
1. Build the `DataWarehouse` database and its `gold` views by following the steps in [sql-data-warehouse-project](https://github.com/NomanAslam12/sql-data-warehouse-project).
2. Run the scripts in any order; each one is standalone. Run the two view scripts last, and run each `CREATE VIEW` only once.
3. `DATETRUNC` requires SQL Server 2022 or later.
## Limitations
 
Recency in both views is measured against `GETDATE()`. Order dates in this dataset are historical, so recency comes out as a large number of months for every customer and product. It ranks customers correctly but the absolute values mean little. Anchoring it to `MAX(order_date)` in the fact table would fix that.
 

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
| Customers | 18,484 |

The gap between order lines (60,398) and distinct orders (27,659) is why order counts in this project use `COUNT(DISTINCT order_number)` and not `COUNT(*)`.

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

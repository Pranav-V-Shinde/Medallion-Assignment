# Data Engineering Practice Assignment: Pandas + Python + SQL with Medallion Architecture

## Scenario
You are a Data Engineer for an e-commerce company. Raw orders arrive from ERP, e-commerce, and POS systems. Your job is to build a Bronze → Silver → Gold data pipeline using Python, Pandas, and SQL.

## Files included
- `bronze_raw_transactions.csv`: 1,002,500 rows (1,000,000 transactions plus 2,500 intentional duplicate rows). It includes intentional data-quality issues for practice.
- `customers.csv`: 50,000 customer records.
- `products.csv`: 1,000 product records.
- `ASSIGNMENT_QUESTIONS.md`: tasks only; try solving before checking your own approach.
- `DATA_DICTIONARY.md`: column definitions and suggested rules.

## Architecture
Source CSV files → **Bronze** (store raw data unchanged) → **Silver** (clean, validate, deduplicate, enrich) → **Gold** (business-ready aggregates) → reporting.

Suggested folder structure:
```text
project/
  data/
    bronze_raw_transactions.csv
    customers.csv
    products.csv
  bronze/
  silver/
  gold/
  notebooks/
  sql/
```

## Learning goals
1. Read and profile large CSV files with Pandas.
2. Handle nulls, duplicates, invalid values, and referential integrity.
3. Use SQL joins, CTEs, CASE, GROUP BY, HAVING, and window functions.
4. Build Bronze, Silver, and Gold outputs.
5. Create incremental-load logic using `last_modified`.
6. Validate row counts and reconcile totals across layers.

## Recommended rules (you may document and justify alternatives)
- Keep the original source file unchanged in Bronze.
- A valid transaction must have a non-null `transaction_id`, `order_date`, `customer_id`, `product_id`, `quantity`, and `unit_price`.
- `customer_id` must exist in `customers.csv`; `product_id` must exist in `products.csv`.
- `quantity` must be greater than 0.
- `discount_pct` must be between 0 and 1 inclusive.
- Keep one row per `transaction_id`; if duplicates differ, retain the row with the latest `last_modified`.
- Calculate `gross_amount = quantity * unit_price`.
- Calculate `discount_amount = gross_amount * discount_pct`.
- Calculate `net_amount = gross_amount - discount_amount`.
- For revenue reporting, count only `Completed` orders. Keep Cancelled, Returned, and Pending statuses available for operational metrics.
- Do not silently delete rejected rows. Write them to a quarantine/reject file with a reason.

## Questions

### Part A — Python and Pandas fundamentals
1. Load the transactions CSV and display the first 10 rows.
2. Print row count, column count, column names, and data types.
3. Find null counts and null percentages for every column.
4. Find duplicate rows and duplicate `transaction_id` values.
5. Show the top 10 most frequent order statuses.
6. Find minimum and maximum `order_date`.
7. Identify columns that need type conversion and convert dates/numeric columns safely.
8. Read the large CSV in chunks of 100,000 rows and calculate total rows without loading the full file at once.
9. Find the top 10 customers by transaction count.
10. Calculate gross, discount, and net amount using vectorized Pandas operations (avoid row-wise `apply` where possible).

### Part B — Bronze layer
11. Explain why Bronze should preserve source data.
12. Copy or register the raw CSV as the immutable Bronze input and record file name, load timestamp, and row count in a simple audit table/CSV.
13. Create a file-level validation report: file exists, schema columns present, and row count.
14. Identify malformed or invalid records, but do not overwrite the source file.
15. Create an ingestion audit record for each run.

### Part C — Silver layer cleaning
16. Standardize column names to lowercase snake_case.
17. Convert `order_date` and `last_modified` to datetime and numeric fields to suitable types.
18. Remove duplicate transactions using `transaction_id` and latest `last_modified`.
19. Validate required fields and create a `reject_reason` for each rejected row.
20. Separate records with missing required values into `silver_rejected.csv`.
21. Reject rows with quantity <= 0.
22. Reject rows where discount_pct is outside 0–1.
23. Find customer IDs missing from the customer master.
24. Find product IDs missing from the product master.
25. Join valid transactions with customer and product master data.
26. Handle unexpected order statuses by flagging them rather than silently changing them.
27. Save cleaned valid data as Parquet (or CSV if Parquet support is not installed).
28. Report counts: source rows, duplicate rows, valid rows, rejected rows, and final Silver rows.

### Part D — SQL practice
Use SQLite, PostgreSQL, SQL Server, or another SQL engine. Load the Silver transactions and dimensions into tables.

29. Write a query to return the 10 highest-value completed transactions.
30. Find total completed revenue by month.
31. Find revenue by product category.
32. Find the top 10 customers by completed revenue.
33. Find order count and revenue by city and state.
34. Calculate completed, cancelled, returned, and pending order counts.
35. Find customers who have never placed a completed order.
36. Find products with no transactions.
37. Use `ROW_NUMBER()` to find the latest transaction per customer.
38. Use `DENSE_RANK()` to rank product categories by revenue.
39. Use a CTE to calculate monthly revenue and month-over-month change.
40. Find duplicate `transaction_id` values using `GROUP BY` and `HAVING`.
41. Find customers whose completed revenue is above the average customer revenue.
42. Calculate each category's percentage contribution to total completed revenue.
43. Find the running total of daily completed revenue using a window function.

### Part E — Gold layer business metrics
44. Build `gold_monthly_sales`: month, order_count, gross_revenue, discount_amount, net_revenue.
45. Build `gold_category_sales`: category, order_count, net_revenue, revenue_rank.
46. Build `gold_customer_360`: customer, city, segment, completed_order_count, lifetime_revenue, last_order_date.
47. Build `gold_order_status_summary`: status, order_count, percentage_of_orders.
48. Build `gold_daily_sales`: order_date, completed_orders, net_revenue, running_revenue.
49. Explain which Gold tables are suitable for dashboards and why.
50. Reconcile Silver totals against Gold aggregates and explain any differences.

### Part F — Incremental processing and reliability
51. Use `last_modified` as a watermark and select only records newer than the previous watermark.
52. Store the last successful watermark in a control table.
53. Explain how you would avoid missing records when multiple rows share the same timestamp.
54. Make the pipeline rerunnable without double-counting transactions (idempotency).
55. Add logging, exception handling, and a failed-run audit status.
56. Design a retry strategy and explain which errors should not be retried.
57. Explain how you would process a file that arrives late or is re-uploaded.
58. Describe how you would scale from Pandas to PySpark when the dataset no longer fits memory.

### Part G — Final mini-project
59. Implement the full pipeline: raw CSV → Bronze audit → Silver cleaning and quarantine → Gold aggregates.
60. Submit:
   - Python/Pandas script or notebook
   - SQL file containing answers to questions 29–43
   - Silver clean and rejected record counts
   - Gold output tables/files
   - Data-quality report
   - A one-page explanation of your Medallion Architecture and design choices

## Evaluation checklist
- Correctness of cleaning and deduplication
- No silent deletion of rejected records
- SQL correctness and readability
- Accurate financial calculations and aggregations
- Reproducibility and idempotency
- Clear audit logs and documentation

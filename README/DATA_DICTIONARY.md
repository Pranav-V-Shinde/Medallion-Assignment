# Data Dictionary

## bronze_raw_transactions.csv
- transaction_id: unique transaction key expected; duplicate rows intentionally exist.
- order_date: transaction date in 2025.
- customer_id: customer foreign key; some null and unknown IDs are intentionally injected.
- product_id: product foreign key.
- quantity: units purchased; some non-positive values are intentionally injected.
- unit_price: product unit price at transaction time.
- discount_pct: decimal discount, expected range 0.00–1.00; invalid values are intentionally injected.
- payment_method: payment channel; a small number of nulls are intentionally injected.
- order_status: Completed, Cancelled, Returned, or Pending.
- sales_channel: Website, Mobile App, or Store.
- source_system: ERP, Ecommerce, or POS.
- last_modified: update timestamp used for incremental-load exercises.

## customers.csv
- customer_id: customer primary key.
- customer_name: synthetic customer name.
- email: synthetic example.com email.
- city / state: customer geography.
- signup_date: customer signup date.
- customer_segment: Retail, Corporate, Small Business, or Premium.

## products.csv
- product_id: product primary key.
- product_name: synthetic product name.
- category: product category.
- unit_price: reference list price.
- supplier_id: synthetic supplier identifier.

## Notes
All records are synthetic and created for practice; they do not represent real people or transactions.

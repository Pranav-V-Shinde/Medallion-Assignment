-- SQLite starter schema (adjust types/syntax for your SQL engine)
CREATE TABLE silver_transactions (
    transaction_id INTEGER,
    order_date TEXT,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price REAL,
    discount_pct REAL,
    payment_method TEXT,
    order_status TEXT,
    sales_channel TEXT,
    source_system TEXT,
    last_modified TEXT,
    gross_amount REAL,
    discount_amount REAL,
    net_amount REAL
);

-- Example: monthly completed revenue
SELECT substr(order_date, 1, 7) AS sales_month,
       COUNT(*) AS completed_orders,
       SUM(net_amount) AS net_revenue
FROM silver_transactions
WHERE order_status = 'Completed'
GROUP BY substr(order_date, 1, 7)
ORDER BY sales_month;

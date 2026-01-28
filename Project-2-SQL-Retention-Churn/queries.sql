-- Project 2: Customer Retention & Churn Analysis
-- Dataset: Olist E-commerce (PostgreSQL)

-- 1. Total Customers
SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;

-- 2. Repeat Customers (>1 order)
SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT c.customer_unique_id
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) t;

-- 3. Repeat Rate (%)
SELECT
    ROUND(
        (COUNT(*)::decimal / (SELECT COUNT(DISTINCT customer_unique_id) FROM customers)) * 100,
        2
    ) AS repeat_rate_percent
FROM (
    SELECT c.customer_unique_id
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) t;

-- 4. Churn Rate (% customers with only 1 order)
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order,
        MAX(o.order_purchase_timestamp) AS last_order
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    ROUND(
        SUM(CASE WHEN first_order = last_order THEN 1 ELSE 0 END)::decimal
        / COUNT(*) * 100,
        2
    ) AS churn_rate_percent
FROM customer_orders;

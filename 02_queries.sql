-- ============================================================
-- Retail Sales Analytics — Business Questions in SQL
-- Organized from basic to advanced. Each query answers a real
-- business question, the kind an interviewer actually asks.
-- ============================================================

-- ---------- LEVEL 1: Basic SELECT / WHERE / ORDER BY ----------

-- Q1. List all orders placed in December 2023.
SELECT order_id, customer_id, order_date, ship_mode
FROM orders
WHERE order_date BETWEEN '2023-12-01' AND '2023-12-31'
ORDER BY order_date;

-- Q2. Find all Technology products priced above 5000.
SELECT product_name, category, unit_price
FROM products
WHERE category = 'Technology' AND unit_price > 5000
ORDER BY unit_price DESC;

-- Q3. Find all Corporate segment customers from the South region.
SELECT customer_name, segment, region, state
FROM customers
WHERE segment = 'Corporate' AND region = 'South';


-- ---------- LEVEL 2: Aggregate functions + GROUP BY ----------

-- Q4. Total revenue and number of orders per region.
--     Revenue = quantity * unit_price * (1 - discount)
SELECT
    o.region,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.region
ORDER BY total_revenue DESC;

-- Q5. Average order value (AOV) per customer segment.
SELECT
    c.segment,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
          / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.segment
ORDER BY avg_order_value DESC;

-- Q6. Which categories generate the most profit?
--     Profit = revenue - (quantity * unit_cost)
SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue,
    SUM(oi.quantity * oi.unit_cost)                       AS cost,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        - SUM(oi.quantity * oi.unit_cost)                 AS profit
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY profit DESC;


-- ---------- LEVEL 3: HAVING (filtering on aggregates) ----------

-- Q7. Sub-categories with total revenue over 100,000.
SELECT
    p.sub_category,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.sub_category
HAVING SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) > 100000
ORDER BY revenue DESC;

-- Q8. Customers who placed more than 5 orders (loyal customers).
SELECT
    c.customer_id, c.customer_name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 5
ORDER BY order_count DESC;


-- ---------- LEVEL 4: Multi-table JOINs (3-4 tables) ----------

-- Q9. Full order detail report: order, customer, product, and line revenue.
SELECT
    o.order_id, o.order_date, c.customer_name, c.region,
    p.product_name, p.category,
    oi.quantity, oi.discount,
    ROUND(oi.quantity * oi.unit_price * (1 - oi.discount), 2) AS line_revenue
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p      ON p.product_id = oi.product_id
ORDER BY o.order_date DESC;

-- Q10. Top 5 best-selling products by quantity sold.
SELECT
    p.product_name, p.category, SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name, p.category
ORDER BY total_units_sold DESC
LIMIT 5;                              -- SQL Server: use TOP 5 instead


-- ---------- LEVEL 5: Subqueries ----------

-- Q11. Customers who have never placed an order (using NOT IN + subquery).
SELECT customer_id, customer_name
FROM customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);

-- Q12. Products priced above the average price of their own category.
SELECT product_name, category, unit_price
FROM products p1
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM products p2
    WHERE p2.category = p1.category
)
ORDER BY category, unit_price DESC;


-- ---------- LEVEL 6: CTEs (Common Table Expressions) ----------

-- Q13. Monthly revenue trend using a CTE.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_date)                        AS order_month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount))       AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT order_month, revenue
FROM monthly_revenue
ORDER BY order_month;
-- SQL Server equivalent for DATE_TRUNC('month', order_date):
--   DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)

-- Q14. Customer lifetime value (CLV) ranked, using a CTE.
WITH customer_revenue AS (
    SELECT
        c.customer_id, c.customer_name, c.segment,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS lifetime_value
    FROM customers c
    JOIN orders o        ON o.customer_id = c.customer_id
    JOIN order_items oi  ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name, c.segment
)
SELECT *
FROM customer_revenue
ORDER BY lifetime_value DESC
LIMIT 10;


-- ---------- LEVEL 7: Window functions ----------

-- Q15. Rank products by revenue within each category (RANK).
SELECT
    category, product_name, revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
FROM (
    SELECT
        p.category, p.product_name,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
) t
ORDER BY category, rank_in_category;

-- Q16. Running total of revenue by month (window function).
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)                    AS order_month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount))   AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT
    order_month, revenue,
    SUM(revenue) OVER (ORDER BY order_month) AS running_total_revenue
FROM monthly
ORDER BY order_month;

-- Q17. Each customer's most recent order (ROW_NUMBER).
SELECT customer_id, order_id, order_date FROM (
    SELECT
        customer_id, order_id, order_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM orders
) t
WHERE rn = 1;


-- ---------- LEVEL 8: Views (for reuse / Power BI import) ----------

-- Q18. A reusable view that pre-joins everything Power BI needs.
CREATE VIEW vw_sales_detail AS
SELECT
    o.order_id, o.order_date, o.ship_date, o.ship_mode,
    c.customer_id, c.customer_name, c.segment, c.region, c.state,
    p.product_id, p.product_name, p.category, p.sub_category,
    oi.quantity, oi.discount,
    oi.quantity * oi.unit_price * (1 - oi.discount)  AS revenue,
    oi.quantity * oi.unit_cost                        AS cost,
    (oi.quantity * oi.unit_price * (1 - oi.discount))
        - (oi.quantity * oi.unit_cost)                 AS profit
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p      ON p.product_id = oi.product_id;

-- Q19. Using the view: profit margin % by region.
SELECT
    region,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(revenue), 0), 2) AS profit_margin_pct
FROM vw_sales_detail
GROUP BY region
ORDER BY profit_margin_pct DESC;

-- Q20. Using the view: year-over-year revenue growth.
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS order_year,
        SUM(revenue)                   AS revenue
    FROM vw_sales_detail
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT
    order_year, revenue,
    LAG(revenue) OVER (ORDER BY order_year)               AS prev_year_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY order_year))
          * 100.0 / NULLIF(LAG(revenue) OVER (ORDER BY order_year), 0), 2)
                                                            AS yoy_growth_pct
FROM yearly
ORDER BY order_year;

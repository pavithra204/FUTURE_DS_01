-- ============================================================
-- Retail Sales Analytics — Database Schema
-- Works in SQL Server (SSMS), PostgreSQL, or MySQL with minor tweaks.
-- ============================================================

CREATE TABLE customers (
    customer_id     VARCHAR(10)     PRIMARY KEY,
    customer_name   VARCHAR(100)    NOT NULL,
    segment         VARCHAR(20)     NOT NULL,   -- Consumer / Corporate / Home Office
    region          VARCHAR(20)     NOT NULL,
    state           VARCHAR(50)     NOT NULL,
    signup_date     DATE            NOT NULL
);

CREATE TABLE products (
    product_id      VARCHAR(10)     PRIMARY KEY,
    product_name    VARCHAR(100)    NOT NULL,
    category        VARCHAR(30)     NOT NULL,
    sub_category    VARCHAR(30)     NOT NULL,
    unit_cost       DECIMAL(10,2)   NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL
);

CREATE TABLE orders (
    order_id        VARCHAR(10)     PRIMARY KEY,
    customer_id     VARCHAR(10)     NOT NULL,
    order_date      DATE            NOT NULL,
    ship_date       DATE            NOT NULL,
    ship_mode       VARCHAR(20)     NOT NULL,
    region          VARCHAR(20)     NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id   INT             PRIMARY KEY,
    order_id        VARCHAR(10)     NOT NULL,
    product_id      VARCHAR(10)     NOT NULL,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,
    unit_cost       DECIMAL(10,2)   NOT NULL,
    discount        DECIMAL(4,2)    NOT NULL DEFAULT 0,   -- e.g. 0.10 = 10%
    CONSTRAINT fk_items_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- Helpful indexes for the joins/aggregations used in 02_queries.sql
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_items_order       ON order_items(order_id);
CREATE INDEX idx_items_product     ON order_items(product_id);

-- ============================================================
-- Import notes:
--  - In SSMS: right-click database -> Tasks -> Import Flat File,
--    map each CSV (customers.csv, products.csv, orders.csv,
--    order_items.csv) to its matching table above, in that order
--    (customers & products first, since orders/order_items
--    reference them via foreign keys).
--  - In PostgreSQL: use \copy customers FROM 'customers.csv' CSV HEADER;
--    (repeat per table, in the same dependency order).
-- ============================================================

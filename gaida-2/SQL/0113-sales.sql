-- 0113-sales.sql

DROP TABLE sales;

CREATE TABLE sales (
    id             INTEGER PRIMARY KEY,
    order_date     DATE NOT NULL,
    customer_id    VARCHAR(10) NOT NULL,
    product_id     VARCHAR(10) NOT NULL,
    product_name   VARCHAR(50) NOT NULL,
    category       VARCHAR(20) NOT NULL,
    quantity       INTEGER NOT NULL,
    unit_price     INTEGER NOT NULL,
    total_amount   INTEGER NOT NULL,
    sales_rep      VARCHAR(30) NOT NULL,
    region         VARCHAR(20) NOT NULL
);

SELECT * FROM sales;


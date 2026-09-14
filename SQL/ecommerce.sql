CREATE DATABASE ecommerce_analyst;
USE ecommerce_analyst;
DROP DATABASE ecommerce_anakytics;
USE ecommerce_analyst;
USE ecommerce_analytics;
CREATE TABLE customers (
    customer_id VARCHAR(50) NOT NULL,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10),
    PRIMARY KEY (customer_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date VARCHAR(30),
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),

    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE payments (
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),

    PRIMARY KEY (order_id, payment_sequential)
);
USE ecommerce_analyst;

    CREATE TABLE reviews (
    review_id VARCHAR(100),
    order_id VARCHAR(100),
    review_score VARCHAR(20),
    review_comment_title TEXT,
    review_comment_message TEXT
);
USE ecommerce_analyst;

CREATE TABLE orders (
    order_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30),
    order_purchase_timestamp VARCHAR(30),
    order_approved_at VARCHAR(30),
    order_delivered_carrier_date VARCHAR(30),
    order_delivered_customer_date VARCHAR(30),
    order_estimated_delivery_date VARCHAR(30),

    PRIMARY KEY (order_id)
);
USE ecommerce_analytics;

CREATE TABLE products (
    product_id VARCHAR(50) NOT NULL,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2),

    PRIMARY KEY (product_id)
);
USE ecommerce_analytics;

CREATE TABLE sellers (
    seller_id VARCHAR(50) NOT NULL,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10),

    PRIMARY KEY (seller_id)
);
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_order FROM order_items;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_payments FROM payments;
SELECT COUNT(*) AS total_payments FROM products;
SELECT COUNT(DISTINCT product_id) FROM products;
SELECT COUNT(*) FROM products WHERE product_id IS NULL;
USE ecommerce_analyst;
SELECT COUNT(*) AS total_sellers FROM sellers;
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'payments', COUNT(*) FROM payments;
SELECT COUNT(*) AS unmatched_orders FROM orders o LEFT JOIN customers c ON o.customer_id=c.customer_id WHERE c.customer_id IS NULL;
SELECT COUNT(*) AS unmatched_order_items FROM order_items oi LEFT JOIN orders o ON oi.order_id=o.order_id WHERE o.order_id IS NULL;
-- =====================================
-- 1. TOTAL ORDERS
-- =====================================
SELECT COUNT(*) AS total_orders FROM orders;
-- =====================================
-- 2. TOTAL CUSTOMERS
-- =====================================
SELECT COUNT(DISTINCT customer_unique_id) AS total_customers FROM customers;
-- =====================================
-- 3. TOTAL PRODUCTS
-- =====================================
SELECT COUNT(*) AS total_products FROM products;
-- =====================================
-- 4. TOTAL SELLERS
-- =====================================
SELECT COUNT(*) AS total_sellers FROM sellers;
-- =====================================
-- 5. TOTAL REVENUE
-- =====================================
SELECT ROUND(SUM(price),2) AS total_revenue FROM order_items;
-- =====================================
-- 6. AVERAGE ORDER VALUE
-- =====================================
SELECT ROUND(SUM(price) / COUNT(DISTINCT order_id),2) AS average_order_value FROM order_items;
-- =====================================
-- 7. MONTHLY SALES ANALYSIS
-- =====================================
SELECT DATE_FORMAT(STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),'%Y-%m') AS month, ROUND(SUM(oi.price),2) AS revenue FROM orders o JOIN order_items oi ON o.order_id=oi.order_id GROUP BY month ORDER BY month;
SELECT order_purchase_timestamp FROM orders LIMIT 10;

-- =========================================
-- 8. PRODUCT ANALYSIS 
-- I. WHICH PRODUCTS GENERATE HIGHEST REVENUE ?
-- =========================================
SELECT oi.product_id,ROUND(SUM(oi.price),2)AS total_revenue ,COUNT(*) AS unit_solds FROM order_items oi GROUP BY oi.product_id ORDER BY total_revenue DESC LIMIT 10;

-- =====================================
-- 9. TOP PRODUCT CATEGORIES BY REVENUE 
-- =====================================
SELECT p.product_category_name AS category , ROUND(SUM(oi.price),2) AS total_revenue ,COUNT(*) AS units_sold FROM order_items oi JOIN products p ON oi.product_id=p.product_id GROUP BY p.product_category_name ORDER BY total_revenue DESC LIMIT 10;

-- =====================================
-- 10.AVERAGE PRODUCT PRICE BY CATEGORY
-- =====================================
SELECT p.product_category_name AS category, ROUND(AVG(oi.price),2) AS average_price FROM order_items oi JOIN products p ON oi.product_id=p.product_id WHERE p.product_category_name IS NOT NULL GROUP BY p.product_category_name ORDER BY average_price DESC;
 
 -- =====================================
-- 11. MOST SOLD PRODUCTS
-- ======================================
SELECT product_id,COUNT(*) AS units_sold FROM order_items GROUP BY product_id ORDER BY units_sold DESC LIMIT 10;

-- =====================================
-- 12. CUSTOMER ANALYSIS
-- =====================================
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price), 2) AS total_spent,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- =====================================
-- 13.	REPEATED CUSTOMERS
-- =====================================
SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) AS customer_orders;

-- =====================================
-- 14. ONE TIME VS REPEATED CUSTOMERS
-- =====================================
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders
GROUP BY customer_type;

-- =====================================
-- 15.AVERAGE SPENDING PER CUSTOMER
-- =====================================
SELECT
    ROUND(AVG(total_spent), 2) AS average_customer_spend
FROM (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) AS customer_spending;

-- =====================================
-- 16.SELLER ANALYSIS
-- =====================================
-- =====================================
-- I.TOP 10 SELLERS BY REVENUE
-- =====================================
SELECT
    seller_id,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(*) AS units_sold
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;
-- =====================================
-- II.TOP SELLERS BY NO.OF ORDERS 
-- =====================================
SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;

-- =====================================
-- III.SELLER STATE PERFORMANCE 
-- =====================================
SELECT
    s.seller_state,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;
-- =====================================
-- PAYMENT ANALYSIS
-- =====================================
SELECT
    payment_type,
    COUNT(*) AS transactions
FROM payments
GROUP BY payment_type
ORDER BY transactions DESC;
-- =====================================
-- 1.REVENUE BY PAYMENT TYPE
-- =====================================
SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;
-- =====================================
-- II.AVERAGE PAYMENT VALUE
-- =====================================
SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM payments
GROUP BY payment_type
ORDER BY average_payment DESC;
-- =====================================
-- III.INSTALLMENT ANALYSIS
-- =====================================
SELECT
    payment_type,
    ROUND(AVG(payment_installments), 2) AS avg_installments
FROM payments
GROUP BY payment_type
ORDER BY avg_installments DESC;

-- =====================================
-- MONTH OVER MONTH GROWTH REVENUE 
-- =====================================
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),
            '%Y-%m'
        ) AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100,
        2
    ) AS mom_growth_percent
FROM monthly_sales
ORDER BY month;
-- =====================================
-- RANK SELLERS BY REVENUE
-- =====================================
WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
)
SELECT
    seller_id,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (ORDER BY revenue DESC) AS seller_rank
FROM seller_revenue
ORDER BY seller_rank;
-- =====================================
-- TOP 3 SELLERS
-- =====================================
WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
),
ranked_sellers AS (
    SELECT
        seller_id,
        revenue,
        RANK() OVER (ORDER BY revenue DESC) AS seller_rank
    FROM seller_revenue
)

SELECT
    seller_id,
    ROUND(revenue, 2) AS revenue,
    seller_rank
FROM ranked_sellers
WHERE seller_rank <= 3
ORDER BY seller_rank;

-- =====================================
-- REVENUE CONTRIBUTION
-- =====================================
WITH category_sales AS (
    SELECT
        p.product_category_name AS category,
        SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE p.product_category_name IS NOT NULL
    GROUP BY p.product_category_name
)
SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue / SUM(revenue) OVER () * 100,2
    ) AS revenue_percentage
FROM category_sales
ORDER BY revenue DESC;
-- =====================================================
-- CASE — Revenue dropped. How would you investigate?
-- =====================================================
SELECT
    DATE_FORMAT(
        STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),
        '%Y-%m'
    ) AS month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;
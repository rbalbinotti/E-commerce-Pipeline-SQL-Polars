/* DATABASE SCHEMA - OLIST E-COMMERCE 
Order of creation to maintain Foreign Key constraints:
1. Independent tables: customers, products, sellers, geolocation
2. Transactional tables: orders
3. Dependent tables: order_items, order_payments, order_reviews
*/

-- DATABASE
CREATE DATABASE Ecommerce;
USE Ecommerce;

-- 1. INDEPENDENT TABLES

CREATE TABLE customers (
    customer_id CHAR(32) PRIMARY KEY,
    customer_unique_id CHAR(32) NOT NULL,
    customer_zip_code_prefix VARCHAR(10) NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state CHAR(2) NOT NULL
);

CREATE TABLE products (
    product_id CHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE sellers (
    seller_id CHAR(32) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10) NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state CHAR(2) NOT NULL,
    INDEX idx_sellers_location (seller_zip_code_prefix)
);

CREATE TABLE geolocation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    geolocation_zip_code_prefix VARCHAR(10) NOT NULL,
    geolocation_lat DECIMAL(18, 15) NOT NULL,
    geolocation_lng DECIMAL(18, 15) NOT NULL,
    geolocation_city VARCHAR(100) NOT NULL,
    geolocation_state CHAR(2) NOT NULL,
    INDEX idx_geo_zip (geolocation_zip_code_prefix)
);
-- We use an artificial id as PK to avoid problems with duplicate ZIP codes.


-- 2. TRANSACTIONAL TABLES

CREATE TABLE orders (
    order_id CHAR(32) PRIMARY KEY,
    customer_id CHAR(32) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE INDEX idx_orders_status ON orders(order_status);


-- 3. DEPENDENT TABLES

CREATE TABLE order_items (
    order_id CHAR(32) NOT NULL,
    order_item_id INT NOT NULL,
    product_id CHAR(32) NOT NULL,
    seller_id CHAR(32) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_items_seller FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE order_payments (
    order_id CHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    review_id CHAR(32) NOT NULL,
    order_id CHAR(32) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME NOT NULL,
    review_answer_timestamp DATETIME,
    CONSTRAINT fk_reviews_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    INDEX idx_order (order_id)
);
-- We keep only this version with an artificial id as PK to avoid duplicates.

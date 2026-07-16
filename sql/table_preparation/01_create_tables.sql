CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INTEGER NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state CHAR(2) NOT NULL
);

CREATE TABLE orders (
	order_id VARCHAR(32) PRIMARY KEY,
	customer_id VARCHAR(32) NOT NULL,
	order_status VARCHAR(32) NOT NULL,
	order_purchase_timestamp TIMESTAMP NOT NULL,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
	order_id VARCHAR(32) NOT NULL,
	order_item_id INTEGER NOT NULL,
	product_id VARCHAR(32) NOT NULL,
	seller_id VARCHAR(32) NOT NULL,
	shipping_limit_date TIMESTAMP NOT NULL,
	price NUMERIC(10,2) NOT NULL,
	freight_value NUMERIC(10,2) NOT NULL,

	PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
	order_id VARCHAR(32) NOT NULL,
	payment_sequential INTEGER NOT NULL,
	payment_type VARCHAR(32) NOT NULL,
	payment_installments INTEGER NOT NULL,
	payment_value NUMERIC(10,2),

	PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE products (
	product_id VARCHAR(32) PRIMARY KEY,
	product_category_name VARCHAR(100) NOT NULL,
	product_name_length INTEGER, 
	product_description_length INTEGER,
	product_photos_qty INTEGER,
	product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE sellers (
	seller_id VARCHAR(32) PRIMARY KEY,
	seller_zip_code_prefix INTEGER NOT NULL,
	seller_city VARCHAR(100) NOT NULL,
	seller_state CHAR(2) NOT NULL
);

CREATE TABLE order_reviews (
    review_id VARCHAR(32),
    order_id VARCHAR(32) NOT NULL,
    review_score SMALLINT NOT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat DOUBLE PRECISION,
    geolocation_lng DOUBLE PRECISION,
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);





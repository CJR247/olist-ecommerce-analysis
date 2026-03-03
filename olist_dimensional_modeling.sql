
-- CREATE VIEW base_fact_sale AS
SELECT
	ooid.order_id,
	ooid.order_item_id,
	ooid.product_id,
	orders.customer_id,
	ooid.seller_id,
	ooid.price AS item_price,
	ooid.freight_value,
	COALESCE(TO_CHAR(orders.order_purchase_timestamp, 'YYYYMMDD')::INT,-1) AS order_date_key,
	COALESCE(TO_CHAR(orders.order_approved_at, 'YYYYMMDD')::INT,-1) AS approved_at_date_key,
	COALESCE(TO_CHAR(orders.order_estimated_delivery_date,'YYYYMMDD')::INT,-1) AS estimated_delivery_date_key,
	COALESCE(TO_CHAR(orders.order_delivered_customer_date, 'YYYYMMDD')::INT,-1) AS customer_delivery_date_key,
	COALESCE(TO_CHAR(orders.order_delivered_carrier_date, 'YYYYMMDD')::INT,-1) AS carrier_delivery_date_key
	FROM olist_order_items_dataset ooid
LEFT JOIN olist_orders_dataset orders ON orders.order_id = ooid.order_id

--find the greatest and least date to create a range of date table

SELECT
    MIN(dt) AS min_date,
    MAX(dt) AS max_date
FROM (
    SELECT order_purchase_timestamp AS dt FROM olist_orders_dataset
    UNION ALL
    SELECT order_approved_at FROM olist_orders_dataset
    UNION ALL
    SELECT order_delivered_carrier_date FROM olist_orders_dataset
    UNION ALL
    SELECT order_delivered_customer_date FROM olist_orders_dataset
) t;

--Create a dim_date table
CREATE TABLE dim_date(
	date_key INT PRIMARY KEY,
	full_date DATE,
	year INT,
	month INT,
	day INT,
	quarter INT,
	week_of_year INT,
	day_of_week INT,
	day_name TEXT,
	month_name TEXT,
	is_weekend BOOLEAN,
	is_month_start BOOLEAN,
	is_month_end BOOLEAN,
	is_year_start BOOLEAN,
	is_year_end BOOLEAN
)

--INSERT -1 row in dim_date to handle null dates

INSERT INTO dim_date VALUES (
    -1, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'Unknown', 'Unknown',
    NULL, NULL, NULL, NULL, NULL
);

--INSERT real date range

INSERT INTO dim_date
SELECT
	TO_CHAR(d, 'YYYYMMDD')::INT AS date_key,
	d AS full_date,
	EXTRACT(YEAR FROM d)::INT AS year,
	EXTRACT(MONTH FROM d)::INT AS month,
	EXTRACT(DAY FROM d)::INT AS day,
	EXTRACT(QUARTER FROM d)::INT AS quarter,
	EXTRACT(WEEK FROM d)::INT AS week_of_year,
	EXTRACT(DOW FROM d)::INT AS day_of_week,
	TO_CHAR(d, 'FMday') AS day_name,
	TO_CHAR(d, 'FMmonth') AS month_name,
	EXTRACT(DOW FROM d) IN (0,6) AS is_weekend,
	d = date_trunc('month', d) AS is_month_start,
    d = (date_trunc('month', d) + INTERVAL '1 month - 1 day')::date AS is_month_end,
    d = date_trunc('year', d)                          AS is_year_start,
    d = (date_trunc('year', d) + INTERVAL '1 year - 1 day')::date AS is_year_end
	
FROM generate_series(
	Date '2015-01-01',
	Date '2030-12-31',
	INTERVAL '1 day'
) AS d;

--Check
SELECT * FROM dim_date


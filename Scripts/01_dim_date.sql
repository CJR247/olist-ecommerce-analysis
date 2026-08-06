-- =====================================================================
-- 01_DIM_DATE.SQL
-- Purpose : Build a conformed date dimension to support all date-based
--           keys used across the fact and dimension views.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Step 1: Determine the min/max date across all date columns in the
--         source data, to size the date range we need to generate.
-- ---------------------------------------------------------------------
SELECT
    MIN(dt) AS min_date,
    MAX(dt) AS max_date
FROM (
    SELECT order_purchase_timestamp     AS dt FROM olist_orders_dataset
    UNION ALL
    SELECT order_approved_at            FROM olist_orders_dataset
    UNION ALL
    SELECT order_delivered_carrier_date FROM olist_orders_dataset
    UNION ALL
    SELECT order_delivered_customer_date FROM olist_orders_dataset
) t;

-- ---------------------------------------------------------------------
-- Step 2: Create the date dimension table.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS  dim_date CASCADE;
CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,
    full_date       DATE,
    year            INT,
    month           INT,
    day             INT,
    quarter         INT,
    week_of_year    INT,
    day_of_week     INT,
    day_name        TEXT,
    month_name      TEXT,
	start_of_month DATE,
	start_of_quarter DATE,
	start_of_week DATE,
    weekend      VARCHAR(10)
);

-- ---------------------------------------------------------------------
-- Step 3: Insert a "-1 / Unknown" row so fact tables can use
--         COALESCE(..., -1) to safely map NULL source dates without
--         breaking referential integrity to dim_date.
-- ---------------------------------------------------------------------
INSERT INTO dim_date VALUES (
    -1, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'Unknown', 'Unknown',
    NULL, NULL, NULL, NULL
);

-- ---------------------------------------------------------------------
-- Step 4: Populate the real date range
-- ---------------------------------------------------------------------
TRUNCATE TABLE dim_date;
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
    INITCAP(TO_CHAR(d, 'FMday')) AS day_name,
    INITCAP(TO_CHAR(d, 'FMmonth')) AS month_name,
    date_trunc('month', d)::DATE AS start_of_month,
	date_trunc('quarter', d)::DATE AS start_of_quarter,
	date_trunc('week', d)::DATE AS start_of_week,
	CASE
		WHEN EXTRACT(DOW FROM d) IN (0,6) THEN 'weekend'
		ELSE 'weekday' END AS weekend

FROM generate_series(
    DATE '2015-01-01',
    DATE '2018-10-17',
    INTERVAL '1 day'
) AS d;

-- ---------------------------------------------------------------------
-- Step 5: Expose the date dimension as a view for consistency with the
--         rest of the semantic layer.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS vw_dim_date CASCADE;
CREATE VIEW vw_dim_date AS
SELECT * FROM dim_date;

-- =====================================================================
-- 02_DIM_TIME.SQL
-- Purpose : Build a conformed time dimension to support all time-based
--           keys used across the fact and dimension views.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Step 1: Create the time dimension table.
-- ---------------------------------------------------------------------
CREATE TABLE dim_time (
    time_key     INT PRIMARY KEY,
    time_label   TEXT,
    hour_24      INT,
    hour_12      INT,
    minute       INT,
    am_pm        TEXT,
    time_of_day  TEXT
);

-- ---------------------------------------------------------------------
-- Step 2: Insert a "-1 / Unknown" row so fact tables can use
--         COALESCE(..., -1) to safely map NULL source times without
--         breaking referential integrity to dim_time.
-- ---------------------------------------------------------------------
INSERT INTO dim_time VALUES (
    -1, 'Unknown', NULL, NULL, NULL, 'Unknown', 'Unknown'
);

-- ---------------------------------------------------------------------
-- Step 3: Populate all 1,440 time rows (24 hours × 60 minutes).
-- ---------------------------------------------------------------------
INSERT INTO dim_time
SELECT
    (LPAD(h::TEXT, 2, '0') || LPAD(m::TEXT, 2, '0'))::INT AS time_key,Q
    LPAD(h::TEXT, 2, '0') || ':' || LPAD(m::TEXT, 2, '0') AS time_label,
    h AS hour_24,
    CASE WHEN h = 0  THEN 12
         WHEN h > 12 THEN h - 12
         ELSE h END AS hour_12,
    m AS minute,
    CASE WHEN h < 12 THEN 'AM' ELSE 'PM' END AS am_pm,
    CASE
        WHEN h BETWEEN 6  AND 11 THEN 'Morning'
        WHEN h BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN h BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day
FROM generate_series(0, 23) AS h
CROSS JOIN generate_series(0, 59) AS m
ORDER BY time_key;

-- ---------------------------------------------------------------------
-- Step 4: Expose the time dimension as a view for consistency with the
--         rest of the semantic layer.
-- ---------------------------------------------------------------------
CREATE VIEW vw_dim_time AS
SELECT * FROM dim_time;

SELECT * FROM vw_dim_time


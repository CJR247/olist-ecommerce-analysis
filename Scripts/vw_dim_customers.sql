-- ---------------------------------------------------------------------
-- vw_dim_customers
-- Grain    : one row per customer_unique_id
-- Notes    : olist_customers_dataset has one row per customer_id, but
--            a single real-world customer can have several customer_id
--            values across orders. We collapse to customer_unique_id
--            and pick the most recent customer_id record (ORDER BY
--            customer_id DESC) as the representative row. Average
--            geolocation lat/lng is attached via zip code prefix.
-- ---------------------------------------------------------------------
CREATE VIEW vw_dim_customers AS

WITH cte_geo AS(
SELECT
	geolocation_zip_code_prefix,
	AVG(geolocation_lat) AS lat,
	AVG(geolocation_lng) AS lng
FROM olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix
),
cte_rank AS(
SELECT
	ocd.customer_unique_id,
	ocd.customer_zip_code_prefix,
	ocd.customer_city,
	ocd.customer_state,
	geo.lat,
	geo.lng,
	ROW_NUMBER() OVER (
		PARTITION BY ocd.customer_unique_id
		ORDER BY ocd.customer_id DESC
		) AS rn
FROM olist_customers_dataset ocd
LEFT JOIN cte_geo geo
	ON geo.geolocation_zip_code_prefix = ocd.customer_zip_code_prefix
)
SELECT
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    lat,
    lng
FROM cte_rank
WHERE rn = 1
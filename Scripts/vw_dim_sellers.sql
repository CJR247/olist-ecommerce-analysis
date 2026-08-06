-- ---------------------------------------------------------------------
-- vw_dim_sellers
-- Grain    : one row per seller_id
-- Notes    : Average geolocation lat/lng attached via zip code prefix.
-- ---------------------------------------------------------------------
CREATE VIEW vw_dim_sellers AS

WITH cte_geo AS(
    SELECT
        geolocation_zip_code_prefix,
        AVG(geolocation_lat) AS lat,
        AVG(geolocation_lng) AS lng
    FROM olist_geolocation_dataset
    GROUP BY geolocation_zip_code_prefix
)
SELECT
    osd.seller_id,
    osd.seller_zip_code_prefix,
    osd.seller_city,
    osd.seller_state,
    geo.lat,
    geo.lng
FROM olist_sellers_dataset osd
LEFT JOIN  cte_geo geo
	ON geo.geolocation_zip_code_prefix = osd.seller_zip_code_prefix;
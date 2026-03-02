WITH cte_ctegory AS 
	(
	SELECT 
	product_id,
	pct.product_category_name,
	COALESCE(product_category_name_english,'unspecified') AS product_category
	FROM olist_products_dataset opd
	LEFT JOIN product_category_translation pct ON opd.product_category_name = pct.product_category_name
	),
	
	cte_geolocation AS
	(
	SELECT
	geolocation_zip_code_prefix,
	AVG(geolocation_lat) AS lat,
	AVG(geolocation_lng) AS lng
	FROM olist_geolocation_dataset
	GROUP BY geolocation_zip_code_prefix
	)

SELECT
	ooid.order_id,
	ooid.order_item_id,
	ooid.product_id,
	category.product_category,
	ooid.price AS item_price,
	ooid.freight_value,
	ooid.seller_id,
	orders.order_purchase_timestamp AS order_date,
	orders.order_approved_at,
	orders.order_estimated_delivery_date,
	orders.order_delivered_customer_date,
	customer.customer_id,
	geo.lat,
	geo.lng
	FROM olist_order_items_dataset ooid
INNER JOIN olist_orders_dataset orders ON orders.order_id = ooid.order_id

INNER JOIN olist_customers_dataset customer ON customer.customer_id = orders.customer_id

LEFT JOIN cte_geolocation geo ON geo.geolocation_zip_code_prefix = customer.customer_zip_code_prefix

INNER JOIN cte_ctegory category ON category.product_id = ooid.product_id

-- INNER JOIN cte_payment payment ON payment.order_id = ooid.order_id

-- GROUP BY ooid.order_id, ooid.product_id,item_price,payment_mode, seller_id,order_date,accepted,estimated_delivery,delivery_date,customers_id,
-- 		 geo.lat,geo.lng,category.product_category
		 



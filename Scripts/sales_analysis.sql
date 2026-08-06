WITH cte_main_sale AS(
	SELECT 
		ooid.order_id,
		ooid.product_id,
		pct.product_category_name_english AS category,
		ooid.seller_id, 
		ooid.price, 
		ood.order_purchase_timestamp:: DATE AS order_date  
		FROM olist_order_items_dataset ooid
	 		JOIN olist_orders_dataset ood ON 
			 	ood.order_id = ooid.order_id
			JOIN olist_products_dataset opd ON
				opd.product_id = ooid.product_id
			JOIN product_category_translation pct ON
				pct.product_category_name = opd.product_category_name
),
cte_sale_summary AS(
	SELECT
	EXTRACT(YEAR FROM order_date) AS year,
	EXTRACT(MONTH FROM order_date) AS month,
	category,
	ROUND(SUM(price)::NUMERIC,2) AS total_amount
	FROM cte_main_sale
	GROUP BY year,month,category
),
cte_rank AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(
			PARTITION BY year,month 
			ORDER BY total_amount DESC
			) AS category_rank
		FROM cte_sale_summary
)
SELECT * FROM cte_rank
WHERE category_rank = 1
ORDER BY year, month


SELECT * FROM vw_base_fact_sale

--Total revenue
SELECT 
	ROUND(
		SUM(item_price)::NUMERIC + 
		SUM(freight_value)::NUMERIC,2) FROM vw_base_fact_sale

--Total Orders
SELECT COUNT(DISTINCT(order_id)) FROM vw_base_fact_sale


WITH cte_otd AS(
SELECT COUNT(DISTINCT(order_id)) AS on_time_delivery FROM vw_base_fact_sale f
WHERE estimated_vs_actual_days<0
)
SELECT
	ROUND(MAX(otd.on_time_delivery::NUMERIC)/COUNT(DISTINCT(order_id))*100,2)
FROM vw_base_fact_sale s
CROSS JOIN cte_otd otd

WITH cte_total AS(
SELECT 
	order_id, 
	SUM(item_price)+SUM(freight_value) AS order_value
FROM vw_base_fact_sale
GROUP BY order_id
)
SELECT ROUND(SUM(order_value)::NUMERIC/COUNT(order_id)::NUMERIC,2)FROM cte_total

SELECT *FROM 



	









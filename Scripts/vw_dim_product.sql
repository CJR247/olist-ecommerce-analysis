CREATE VIEW vw_dim_product AS
SELECT 
	product_id,
	product_category_name AS category, 
	product_weight_g AS product_weight 
FROM olist_products_dataset


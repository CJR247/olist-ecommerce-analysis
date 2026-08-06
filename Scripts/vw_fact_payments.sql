CREATE VIEW vw_fact_payments AS
WITH cte_payment_rank AS (
SELECT
	order_id,
	payment_type,
	ROW_NUMBER() OVER 
	(PARTITION BY order_id ORDER BY COUNT(*) DESC) AS rn
FROM olist_order_payments_dataset
GROUP BY order_id, payment_type
),
cte_payment_summary AS (
SELECT
	order_id,
	COUNT(DISTINCT payment_type) AS number_of_payment_methods,
	SUM(payment_installments) AS number_of_installments,
	SUM(payment_value) AS total_value
FROM olist_order_payments_dataset
GROUP BY order_id
),
cte_payment_table AS (
SELECT
	r.order_id,
	r.payment_type,
	s.number_of_payment_methods,
	s.number_of_installments,
	s.total_value
FROM cte_payment_rank r
INNER JOIN cte_payment_summary s 
	ON s.order_id = r.order_id
WHERE r.rn = 1
)
SELECT
    o.order_id,
    ocd.customer_unique_id,
    o.order_status,
    p.payment_type,
    p.number_of_payment_methods,
    p.number_of_installments,
    p.total_value,
    CASE
        WHEN p.number_of_installments = 1  THEN 'Single Payment'
        WHEN p.number_of_installments <= 6 THEN 'Short Installment'
        ELSE                                    'Long Installment'
    END AS installment_category,
    EXTRACT(DAY FROM (o.order_approved_at - o.order_purchase_timestamp)) AS days_to_approval,
    COALESCE(TO_CHAR(o.order_purchase_timestamp, 'YYYYMMDD')::INT, -1) AS order_date_key,
    COALESCE(TO_CHAR(o.order_purchase_timestamp, 'HH24MI')::INT, -1) AS order_time_key,
    COALESCE(TO_CHAR(o.order_approved_at,'YYYYMMDD')::INT, -1) AS approved_date_key,
    COALESCE(TO_CHAR(o.order_approved_at,'HH24MI')::INT, -1) AS approved_time_key
FROM olist_orders_dataset o
LEFT JOIN cte_payment_table p   
	ON p.order_id   = o.order_id
LEFT JOIN olist_customers_dataset ocd 
	ON ocd.customer_id = o.customer_id;


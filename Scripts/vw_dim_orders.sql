-- ---------------------------------------------------------------------
-- vw_dim_orders
-- Grain    : one row per order_id
-- Notes    : olist_order_payments_dataset can have multiple payment
--            rows per order (e.g. split payments, vouchers + credit
--            card). We pick the most frequently used payment_type per
--            order as the representative type, and separately sum
--            installments and total value across all payment rows for
--            that order so no payment amount is lost.
-- ---------------------------------------------------------------------
CREATE VIEW vw_dim_orders AS
WITH cte_payment_rank AS (
    SELECT
        order_id,
        payment_type,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY COUNT(*) DESC) AS rn
    FROM olist_order_payments_dataset
    GROUP BY order_id, payment_type
),
cte_payment_summary AS (
    SELECT
        order_id,
        SUM(payment_installments) AS number_of_installments,
        SUM(payment_value)        AS total_value
    FROM olist_order_payments_dataset
    GROUP BY order_id
),
cte_payment_table AS (
    SELECT
        r.order_id,
        r.payment_type,
        s.number_of_installments,
        s.total_value
    FROM cte_payment_rank r
    INNER JOIN cte_payment_summary s ON r.order_id = s.order_id
    WHERE r.rn = 1
)
SELECT
    o.order_id,
    o.order_status,
    p.payment_type,
    p.number_of_installments,
    p.total_value
FROM olist_orders_dataset o
LEFT JOIN cte_payment_table p ON o.order_id = p.order_id;
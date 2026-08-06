-- ---------------------------------------------------------------------
-- vw_base_fact_sale
-- Grain    : one row per order_item_id (i.e. per line item / unit
--            shipped within an order). This is the lowest-grain sales
--            fact, intended as the base for any higher-level
--            aggregation (e.g. per order, per customer, per seller).
-- ---------------------------------------------------------------------
CREATE VIEW vw_base_fact_sale AS
SELECT
    ooid.order_id,
    ooid.order_item_id,
    ooid.product_id,
    ocd.customer_unique_id,
    ooid.seller_id,
    ooid.price AS item_price,
    ooid.freight_value,

    COALESCE(TO_CHAR(orders.order_purchase_timestamp,'YYYYMMDD')::INT, -1) AS order_date_key,
    COALESCE(TO_CHAR(orders.order_purchase_timestamp,'HH24MI')::INT, -1) AS order_time_key,

    COALESCE(TO_CHAR(orders.order_approved_at,'YYYYMMDD')::INT, -1) AS approved_at_date_key,
    COALESCE(TO_CHAR(orders.order_approved_at,'HH24MI')::INT, -1) AS approved_at_time_key,

    COALESCE(TO_CHAR(orders.order_estimated_delivery_date,'YYYYMMDD')::INT, -1) AS estimated_delivery_date_key,

    COALESCE(TO_CHAR(orders.order_delivered_customer_date,'YYYYMMDD')::INT, -1) AS customer_delivery_date_key,
    COALESCE(TO_CHAR(orders.order_delivered_customer_date,'HH24MI')::INT, -1) AS customer_delivery_time_key,

    COALESCE(TO_CHAR(orders.order_delivered_carrier_date,'YYYYMMDD')::INT, -1) AS carrier_delivery_date_key,
    COALESCE(TO_CHAR(orders.order_delivered_carrier_date,'HH24MI')::INT, -1) AS carrier_delivery_time_key,

    /* Approval duration */
    EXTRACT(EPOCH FROM (
        orders.order_approved_at -
        orders.order_purchase_timestamp
    )) / 3600 AS approval_hours,

    /* Time taken to hand over to carrier */
    EXTRACT(EPOCH FROM (
        orders.order_delivered_carrier_date -
        orders.order_approved_at
    )) / 3600 AS carrier_handover_hours,

    /* Carrier to customer delivery time */
    EXTRACT(EPOCH FROM (
        orders.order_delivered_customer_date -
        orders.order_delivered_carrier_date
    )) / 24 / 3600 AS carrier_to_customer_days,

    /* Total delivery time */
    EXTRACT(EPOCH FROM (
        orders.order_delivered_customer_date -
        orders.order_purchase_timestamp
    )) / 24 / 3600 AS delivery_days,

    /* Difference between estimated and actual delivery */
    EXTRACT(EPOCH FROM (
        orders.order_delivered_customer_date -
        orders.order_estimated_delivery_date
    )) / 24 / 3600 AS estimated_vs_actual_days

FROM olist_order_items_dataset ooid
LEFT JOIN olist_orders_dataset orders
    ON orders.order_id = ooid.order_id
LEFT JOIN olist_customers_dataset ocd
    ON ocd.customer_id = orders.customer_id
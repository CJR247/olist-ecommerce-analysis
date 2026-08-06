-- =====================================================================
-- 04_ANALYSIS_QUERIES.SQL
-- Purpose : Example analytical queries built on top of the views
--           above, demonstrating how the model gets used downstream.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Bulk order customers
-- Identifies customers who place "bulk" orders (3+ line items in a
-- single order) and ranks them by lifetime bulk item volume.
-- ---------------------------------------------------------------------
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS bulk_order_count,
    SUM(total_items)         AS lifetime_bulk_items
FROM (
    SELECT
        order_id,
        customer_unique_id,
        COUNT(order_item_id) AS total_items
    FROM vw_base_fact_sale
    GROUP BY order_id, customer_unique_id
    HAVING COUNT(order_item_id) >= 10
) bulk_orders
GROUP BY customer_unique_id
ORDER BY lifetime_bulk_items DESC;



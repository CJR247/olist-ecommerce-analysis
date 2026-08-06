-- ---------------------------------------------------------------------
-- vw_dim_reviews_fact
-- Grain    : one row per review_id (NOT per order_id, and NOT per
--            order_item_id).
--
-- Why this needs care:
--   olist_order_items_dataset has multiple rows per order_id whenever
--   an order contains more than one unit/product (e.g. quantity > 1
--   shows up as separate order_item_id rows for the same product, and
--   multi-seller orders add distinct seller_id values too). Joining
--   reviews directly to order_items would fan out and duplicate the
--   review_id once per item row.
--
--   Since a review is given at the order level (quantity/items are
--   irrelevant to it), we first collapse order_items down to exactly
--   one seller_id per order_id -- here, the seller from the lowest
--   order_item_id -- using ROW_NUMBER(), then join that single row
--   per order_id back to the reviews table. This guarantees review_id
--   stays unique in the output, while still preserving legitimate
--   cases where a customer left multiple reviews (multiple review_id
--   values) for the same order_id.
--
--   IMPORTANT: the rn = 1 filter is applied in the ON clause, not a
--   WHERE clause. Putting it in WHERE would silently convert this
--   LEFT JOIN into an INNER JOIN, dropping any review whose order has
--   no matching order_items row.
--
-- Caveat: for orders with multiple distinct sellers, seller_id here is
--   a representative value (first item), not a verified attribution.
--   If accurate per-seller review attribution is ever needed, model
--   that as a separate (review_id, seller_id) bridge table instead.
-- ---------------------------------------------------------------------
CREATE VIEW vw_dim_reviews_fact AS
SELECT
    oord.review_id,
    oord.order_id,
    oord.review_score,
    ocd.customer_unique_id,
    ranked.seller_id,
    COALESCE(TO_CHAR(oord.review_creation_date::TIMESTAMP,   'YYYYMMDD')::INT, -1) AS review_creation_date_key,
	COALESCE(TO_CHAR(oord.review_creation_date::TIMESTAMP,   'HH24MI')::INT, -1) AS review_creation_time_key,
    COALESCE(TO_CHAR(oord.review_answer_timestamp::TIMESTAMP,'YYYYMMDD')::INT, -1) AS review_answer_date_key,
	COALESCE(TO_CHAR(oord.review_answer_timestamp::TIMESTAMP,'HH24MI')::INT, -1) AS review_answer_time_key,
	--Reply time days
	    EXTRACT(EPOCH FROM (
        oord.review_answer_timestamp::TIMESTAMP -
        oord.review_creation_date::TIMESTAMP
    )) / 3600 AS reply_time_hours
	
FROM olist_order_reviews_dataset oord
LEFT JOIN olist_orders_dataset    orders ON orders.order_id = oord.order_id
LEFT JOIN olist_customers_dataset ocd    ON ocd.customer_id = orders.customer_id
LEFT JOIN (
    SELECT
        order_id,
        seller_id,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_item_id) AS rn
    FROM olist_order_items_dataset
) ranked ON ranked.order_id = orders.order_id AND ranked.rn = 1;
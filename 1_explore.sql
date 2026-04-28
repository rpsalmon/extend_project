/*---------------------------
get the shape and characteristics of the data
---------------------------*/
--orders
SELECT COUNT(DISTINCT order_id) AS distinct_orders
    , CASE WHEN SUM(total_discount) > 0 THEN AVG(total_discount) END AS avg_discount
    , AVG(total_price) AS avg_price
FROM extend.orders
;

SELECT date_trunc('day', ordered_at) as ordered_at
    , COUNT(DISTINCT order_id) as distinct_orders
    , CASE WHEN SUM(total_discount) > 0 THEN AVG(total_discount) END AS avg_discount
    , AVG(total_price) as avg_price
FROM extend.orders 
GROUP BY 1
;

--order lines
SELECT COUNT(DISTINCT line_item_id) as disticnt_items
    , COUNT(DISTINCT variant_id) as distinct_contract_variants
    , AVG(product_purchase_price) as avg_purchase_price
    , CASE WHEN SUM(discount_per_item) > 0 THEN AVG(discount_per_item) END as avg_discount
FROM extend.order_lines
;

SELECT (SUM(warranty_count)*1.0) / SUM(warrantable_count) as warranty_penetration
    , (SUM(warrantable_count)*1.0) / COUNT(DISTINCT line_item_id) as item_warranty_penetration
FROM (
    SELECT CASE WHEN is_warrantable = 'true' THEN 1 ELSE 0 END AS warrantable_count
        , CASE WHEN is_warranty = 'true' THEN 1 ELSE 0 END AS warranty_count
        , *
    FROM extend.order_lines
    )
;

--merchants
SELECT storetype
    , COUNT(DISTINCT sortkey) AS stores
    , CASE WHEN SUM(merchantcut) > 0 THEN AVG(merchantcut) END AS avg_merchantcut
FROM extend.merchants
GROUP BY 1
;

SELECT storetype
    , (SUM(enabled_count)*1.0) / SUM(approved_count) AS enabled_penetration
FROM (
    SELECT CASE WHEN enabled = 'true' THEN 1 ELSE 0 END AS enabled_count
        , CASE WHEN approved = 'true' THEN 1 ELSE 0 END AS approved_count
        , *
    FROM extend.merchants
    )
GROUP BY 1
;

--contracts
SELECT COUNT(DISTINCT contract_id) as distinct_contracts
    , AVG(plan_purchase_price) as avg_warranty_price
    , AVG(contract_length_years) as avg_contract_length
    , (SUM(refunded)*1.0) / COUNT(DISTINCT contract_id) as refund_rate
FROM (
    SELECT *
        , CASE WHEN is_refunded = 'true' THEN 1 ELSE 0 END AS refunded
    FROM extend.contracts
)
;

SELECT date_trunc('day', ordered_at) as ordered_at
    , COUNT(DISTINCT contract_id) as distinct_contracts
FROM extend.contracts
GROUP BY 1
;

SELECT MIN(ordered_at), MAX(ordered_at)
FROM extend.orders
;

SELECT MIN(ordered_at), MAX(ordered_at)
FROM extend.contracts
;

SELECT MIN(createdat), MAX(createdat)
FROM extend.merchants
;

SELECT count(*)
FROM extend.order_lines as ol
LEFT JOIN extend.contracts as c
ON (ol.line_item_id) = (c.line_item_id)
WHERE c.line_item_id is not null
;
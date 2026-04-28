--attaach rate per month, unit and dollar basis
DROP TABLE IF EXISTS extend.attachment;
CREATE TABLE IF NOT EXISTS extend.attachment AS (
WITH ol AS (
    SELECT c.*
        , ol.*
        , ol.line_item_id as line_item
    FROM extend.order_lines AS ol
    LEFT JOIN extend.contracts AS c
        ON ol.line_item_id = c.line_item_id
    WHERE c.line_item_id IS NOT NULL
)
, mer AS (
    SELECT m.*
        , o.*
    FROM extend.merchants as m
    LEFT JOIN extend.orders AS o
        ON o.store_id = SPLIT_PART(m.sortkey, '::', 2)
)
, joined AS (
    SELECT mer.name
        , mer.storetype
        , mer.order_id
        , ol.line_item
        , CASE WHEN ol.contract_id IS NOT NULL THEN 1 ELSE 0 END AS contract_count
        , CASE WHEN ol.is_warrantable = 'true' THEN 1 ELSE 0 END AS warrantable_count
        , CASE WHEN ol.is_warranty = 'true' THEN 1 ELSE 0 END AS warranty_count
        --, (ol.plan_purchase_price * ol.quantity) AS warranty_rev
        , ol.plan_purchase_price --per item_id
        , (ol.product_purchase_price * ol.quantity) as product_purchase_price --per item_id
        , mer. total_price --per order_id
        , ol.quantity --per item_id
        , date_trunc('day', mer.ordered_at) AS ordered_at
    FROM ol
    LEFT JOIN mer
        ON ol.order_id = mer.order_id
)
SELECT j.storetype
    , j.name
    , date_trunc('month', j.ordered_at) AS ordered_month
    , COUNT(DISTINCT j.order_id) AS orders
    , COUNT(DISTINCT j.line_item) AS items_count --total items
    , SUM(j.quantity) AS items_total
    , SUM(j.contract_count) AS contract_count --warranty contracts
    , SUM(j.warrantable_count) AS warrantable_count --possible to be warrantied
    , SUM(j.warranty_count) AS warranty_count --warranties attached
    , SUM(j.plan_purchase_price * j.warrantable_count) AS warranty_revenue --warranty revenue
    , SUM(j.product_purchase_price ) AS items_revenue
    --, COUNT(DISTINCT j.line_item) AS items_count --total items
FROM joined AS j
GROUP BY 1,2,3
HAVING SUM(j.warrantable_count) > 0
);
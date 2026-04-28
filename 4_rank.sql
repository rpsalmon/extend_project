--merchant rank
DROP TABLE IF EXISTS extend.rank;
CREATE TABLE IF NOT EXISTS extend.rank AS (
WITH ol AS (
    SELECT c.*
        , ol.*
        , (ol.quantity * c.plan_purchase_price) AS warranty_revenue
    FROM extend.order_lines AS ol
    LEFT JOIN extend.contracts AS c
        ON ol.line_item_id = c.line_item_id
)
, mer AS (
    SELECT m.*
        , o.*
        , (1 - m.merchantcut) as extend_cut
    FROM extend.merchants as m
    LEFT JOIN extend.orders AS o
        ON o.store_id = SPLIT_PART(m.sortkey, '::', 2)
)
, joined AS (
        SELECT mer.name
        , mer.storetype
        , SUM(warranty_revenue) AS warranty_revenue
        , COUNT(DISTINCT mer.order_id) AS order_count
        , SUM(extend_cut * warranty_revenue) AS extend_revenue
    FROM mer 
    LEFT JOIN ol 
        ON ol.order_id = mer.order_id
    GROUP BY 1,2
)
SELECT joined.name
    , joined.storetype
    , warranty_revenue
    , order_count
    , extend_revenue::numeric(10,2) as extend_revenue
    , RANK() OVER (PARTITION BY joined.storetype ORDER BY warranty_revenue DESC) AS warranty_rank
    , RANK() OVER (PARTITION BY joined.storetype ORDER BY order_count DESC) AS order_rank
    , RANK() OVER (PARTITION BY joined.storetype ORDER BY extend_revenue DESC) AS extend_rank
FROM joined
WHERE extend_revenue IS NOT NULL
);
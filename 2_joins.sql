--missing merchants in order data
SELECT COUNT(*) AS missing_merchant
FROM extend.orders AS o
LEFT JOIN extend.merchants AS m
    ON o.store_id = SPLIT_PART(m.sortkey, '::', 2)
WHERE m.sortkey IS NULL
;

--missing contracts in order data
SELECT COUNT(*) AS missing_contracts
FROM extend.order_lines AS ol
LEFT JOIN extend.contracts AS c
    ON ol.line_item_id = c.variant_id
WHERE c.contract_id IS NULL
AND ol.is_warranty = 'true'
;

--pricing reconciliation
SELECT o.order_id
    , o.subtotal_price
    , o.total_discount
    , o.total_price AS order_revenue --all items
    , SUM(ol.quantity * ol.product_purchase_price) AS items_revenue
    , COALESCE(SUM(c.plan_purchase_price), 0) AS warranty_revenue
    , SUM(ol.quantity * ol.discount_per_item) AS items_discount
FROM extend.orders AS o
RIGHT JOIN extend.order_lines AS ol
    ON o.order_id = ol.order_id
LEFT JOIN extend.contracts AS c
    ON ol.line_item_id = c.variant_id
WHERE ol.is_warrantable = 'true'
GROUP BY 1,2,3,4
;

--orders from inactive merchants
SELECT o.order_id
    , m.name
    , m.approved
    , m.enabled
FROM extend.orders AS o
LEFT JOIN extend.merchants AS m
    ON o.store_id = SPLIT_PART(m.sortkey, '::', 2)
WHERE m.enabled = 'false' OR m.approved = 'false'
;

---checking for orders before merchant created
SELECT o.order_id
    , o.ordered_at
    , m.createdat
FROM extend.orders AS o
LEFT JOIN extend.merchants AS m
    ON o.store_id = SPLIT_PART(m.sortkey, '::', 2)
WHERE o.ordered_at < m.createdat
;

--checking for dupe contracts
SELECT line_item_id
    , COUNT(DISTINCT contract_id) AS contract_count
FROM extend.contracts
GROUP BY 1
HAVING COUNT(DISTINCT contract_id) > 1
ORDER BY COUNT(DISTINCT contract_id) DESC
;
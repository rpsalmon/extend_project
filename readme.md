# EXTEND PROJECT

1. Create environment <python3 -m venv extend_env>
2. Upload csv to database of choice
3. Install requirements.txt
4. Execute py
5. Launch and run ipynb to follow along

## Data

Explore the data dictionary for more details of seed tables

ordered_at = 2020-03-01 thru 2020-05-31

- Orders
    1. Unique orders
    2. Average discount per order
    3. Average sale price
    4. Order time distribution
- Order_Lines
    1. Unique items per order
    2. Average price
    3. Average discount
    4. Warranty take-rate
- Contracts
    1. Unique contracts
    2. Order time distribution
    3. Average purchase price
    4. Average contract length
    5. Refund rate
- Merchants
    1. Attach rate - per month, unit and dollar basis
        a. Overall
        b. By merchant

## Data Integrity

- line_item_id in contracts and order_lines are mostly distinct ~5k match
- sortkey requires a split_part method to extract and match to store_id
- order_id volume doubles late april into may
- ~36% of all items sold are warrantable but only ~8% of those have a warranty
- Consumer Electronics has enabled > approved, else is 1:1
- Contracts on average sell for ~$40, have a length of 1.63 years, refund about 1% of the time

## Attach Rate

- contract_count = count(contract_id is not null when joined to order_lines)
- warrantable_count = is_warrantable is 'true'
- warranty_count = is_warranty is 'true'
- warranty_revenue = sum(plan_purchase_price)
- items_revenue = sum(product_purchase_price)

## Merchant Industry Insights

- extend_cut = (1-merchantcut)
- extend_revenue = extend_cut * warranty_revenue
- rank() sum(warranty_revenue) by storetype
- rank() sum(order_count) by storetype
- rank() sum(extend_revenue) by storetype

## Follow up investigation

- Something drove sales in early May
- Financial records between orders and order_items do not reconcile
- Orders from unapproved merchants (enabled or approved = 'false')
- Orders from before a merchant createdat
- Contract_id duplicates in contracts table for line_item_id
- High attach rate could indicate where to invest

## 
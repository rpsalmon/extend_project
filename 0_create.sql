/*
create the schema that the data will live in
*/

CREATE SCHEMA IF NOT EXISTS extend;

/*---------------------------
creating the tables before loading the data from csv
---------------------------*/

DROP TABLE IF EXISTS extend.orders;
CREATE TABLE IF NOT EXISTS extend.orders (
    order_id varchar
    , app_id varchar
    , source_name varchar
    , ordered_at timestamp
    , total_price numeric(12,2)
    , subtotal_price numeric(12,2)
    , total_discount numeric(12,2)
    , shipping_country varchar
    , store_id varchar
);

DROP TABLE IF EXISTS extend.order_lines;
CREATE TABLE IF NOT EXISTS extend.order_lines (
    line_item_id varchar
    , order_id varchar
    , variant_id varchar
    , quantity bigint
    , price numeric(12,2) --list price
    , product_purchase_price numeric(12,2) --revenue
    , discount_per_item numeric(12,4)
    , is_warrantable varchar
    , is_warranty varchar
);

DROP TABLE IF EXISTS extend.merchants;
CREATE TABLE IF NOT EXISTS extend.merchants (
    sortkey varchar -- STORE::####store_id#####
    , name varchar
    , createdat timestamp
    , enabled varchar
    , approved varchar
    , merchantcut numeric(12,2)
    , storetype varchar
);

DROP TABLE IF EXISTS extend.contracts;
CREATE TABLE IF NOT EXISTS extend.contracts (
    contract_id varchar
    , variant_id varchar
    , store_id varchar
    , plan_id varchar
    , ordered_at timestamp
    , plan_purchase_price numeric(12,2)
    , is_refunded varchar
    , contract_length_years numeric(12,1)
    , line_item_id varchar
);

/*---------------------------
loading the csv's to the tables
---------------------------*/
COPY extend.orders 
FROM '/Users/myrsmpb/Documents/extend_project/Revenue_Analytics_Takehome_Assessment/data/orders.csv'
DELIMITER ','
CSV HEADER;

COPY extend.order_lines 
FROM '/Users/myrsmpb/Documents/extend_project/Revenue_Analytics_Takehome_Assessment/data/order_lines.csv'
DELIMITER ','
CSV HEADER;

COPY extend.merchants 
FROM '/Users/myrsmpb/Documents/extend_project/Revenue_Analytics_Takehome_Assessment/data/merchants.csv'
DELIMITER ','
CSV HEADER;

COPY extend.contracts 
FROM '/Users/myrsmpb/Documents/extend_project/Revenue_Analytics_Takehome_Assessment/data/contracts.csv'
DELIMITER ','
CSV HEADER;
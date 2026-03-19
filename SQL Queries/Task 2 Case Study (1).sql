-- KoRo  Case Study - Task 2
-- Author: Prajwal Tamang
-- Tool: Google BigQuery
--
-- Objective:
-- 1. Clean the product category table
-- 2. Analyze product category popularity by country
-- 3. Identify the top 5 most ordered products per country
-- 4. Identify the bottom 5 least ordered products per country



-- 1. CLEAN PRODUCT CATEGORY TABLE -----
-- The raw product_universal table does not contain proper ----
-- column names, so we create a cleaned version.

CREATE OR REPLACE TABLE `koro-case-study-490117.koro_case.product_universal_clean` AS
SELECT
  string_field_0 AS sku,
  string_field_1 AS main_category
FROM `koro-case-study-490117.koro_case.product_universal`
WHERE string_field_0 != 'sku';


-- 2. CATEGORY POPULARITY BY COUNTRY
-- Calculate the total number of unique orders by
-- country and main product category

SELECT
  o.country_iso,
  pu.main_category,
  COUNT(DISTINCT o.order_id) AS total_orders

FROM `koro-case-study-490117.koro_case.orders` AS o
JOIN `koro-case-study-490117.koro_case.product_universal_clean` AS pu
  ON o.product_number = pu.sku

GROUP BY
  o.country_iso,
  pu.main_category

ORDER BY total_orders DESC;


-- 3. TOP 5 MOST ORDERED PRODUCTS PER COUNTRY ----
-- Count product orders by country, then rank products ---
-- within each country by descending order volume-----

WITH product_counts AS (
  SELECT
    o.country_iso,
    o.product_number,
    COUNT(DISTINCT o.order_id) AS total_orders
  
  FROM `koro-case-study-490117.koro_case.orders` AS o
  GROUP BY
    o.country_iso,
    o.product_number
),
ranked_top_products AS (
  SELECT
    country_iso,
    product_number,
    total_orders,
    RANK() OVER (
      PARTITION BY country_iso
      ORDER BY total_orders DESC
    ) AS top_rank
  FROM product_counts
)

SELECT
  country_iso,
  product_number,
  total_orders,
  top_rank
FROM ranked_top_products
WHERE top_rank <= 5
ORDER BY country_iso, top_rank, total_orders DESC;


-- 4. BOTTOM 5 LEAST ORDERED PRODUCTS PER COUNTRY ---
-- Count product orders by country, then use ROW_NUMBER() ----
-- to return exactly 5 bottom products per country ----

WITH product_counts AS (
  
  SELECT
    o.country_iso,
    o.product_number,
    COUNT(DISTINCT o.order_id) AS total_orders
  FROM `koro-case-study-490117.koro_case.orders` AS o
  GROUP BY
    o.country_iso,
    o.product_number
),
ranked_bottom_products AS (
  SELECT
    country_iso,
    product_number,
    total_orders,
    
    ROW_NUMBER() OVER (
      PARTITION BY country_iso
      ORDER BY total_orders ASC, product_number
    ) AS bottom_rank
  FROM product_counts
)

SELECT
  country_iso,
  product_number,
  total_orders,
  bottom_rank

FROM ranked_bottom_products
WHERE bottom_rank <= 5
ORDER BY country_iso, bottom_rank ASC;

-- KoRo Case Study - Task 1
-- Author: Prajwal Tamang
-- Tool: Google BigQuery
--
-- Objective:
-- 1. Explore the raw datasets
-- 2. Prepare an order-level table by removing repeated order rows
-- 3. Identify each customer's first order using ROW_NUMBER()
-- 4. Calculate daily new customer share
-- 5. Count orders placed within 10, 15, and 20 days of first order



-- 1.DATA EXPLORATION ---
----     Preview datasets to understand structure and columns -----


SELECT
  string_field_0 AS sku,
  string_field_1 AS main_category
FROM `koro-case-study-490117.koro_case.product_universal`
LIMIT 10;

SELECT *
FROM `koro-case-study-490117.koro_case.orders`
LIMIT 10;

SELECT *
  FROM `koro-case-study-490117.koro_case.product_locale`
  LIMIT 10;

SELECT *
  FROM `koro-case-study-490117.koro_case.product_universal`
  LIMIT 10;


-- 2.ORDER-LEVEL DATA PREPARATION ---
-- Remove repeated product-line rows and keep one row per order ---

CREATE OR REPLACE TABLE `koro-case-study-490117.koro_case.clean_orders` AS

WITH order_level AS (
  SELECT DISTINCT
    order_id,
    customer_id,
    DATE(order_date) AS order_date,
    country_iso
  FROM `koro-case-study-490117.koro_case.orders`
)

SELECT *
FROM order_level;


-- 3. IDENTIFY EACH CUSTOMER'S FIRST ORDER ----
-- Use ROW_NUMBER() partitioned by customer_id ----
--- With a breakdown by reporting_channel from the marketing_sources table ----


-- 3. IDENTIFY EACH CUSTOMER'S FIRST ORDER
-- Use ROW_NUMBER() partitioned by customer_id

WITH order_level AS (
  
  SELECT DISTINCT
    o.order_id,
    o.customer_id,
    DATE(o.order_date) AS order_date,
    o.country_iso
  
  FROM `koro-case-study-490117.koro_case.orders` as o
),

ranked_orders AS (
  
  SELECT
    order_id,
    customer_id,
    order_date,
    country_iso,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY order_date, order_id
    ) AS order_rank
  FROM order_level
)

  
  SELECT *
FROM ranked_orders
ORDER BY customer_id, order_date
LIMIT 20;



---- 4. DAILY NEW CUSTOMER SHARE ---- 

--- For each day:
-- - total number of orders
-- - number of first-time orders
-- - percentage of orders from new customers

WITH order_level AS (
  
  SELECT DISTINCT
    order_id,
    customer_id,
    DATE(order_date) AS order_date,
    country_iso
  
  FROM `koro-case-study-490117.koro_case.orders`
),
ranked_orders AS (
  SELECT
    order_id,
    customer_id,
    order_date,
    country_iso,
    
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY order_date, order_id
    ) AS order_rank
  FROM order_level
)

SELECT
  
  order_date,
  
  COUNT(DISTINCT order_id) AS total_orders,
  
  COUNT(DISTINCT CASE WHEN order_rank = 1 THEN order_id END) AS first_time_orders,
  ROUND(
    100 * COUNT(DISTINCT CASE WHEN order_rank = 1 THEN order_id END)
    / COUNT(DISTINCT order_id),
    2
  ) AS pct_orders_from_new_customers

FROM ranked_orders

GROUP BY order_date

ORDER BY order_date;




-- 5. CUSTOMER RETENTION WINDOW ANALYSIS

-- Count how many orders each customer placed within
-- 10, 15, and 20 days after their first order

WITH order_level AS (
  SELECT DISTINCT
    order_id,
    customer_id,
    DATE(order_date) AS order_date,
    country_iso
  FROM `koro-case-study-490117.koro_case.orders`
),

ranked_orders AS (
  SELECT
    order_id,
    customer_id,
    order_date,
    country_iso,
    
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY order_date, order_id
    ) AS order_rank
  FROM order_level
),
first_orders AS (
  SELECT
    customer_id,
    order_date AS first_order_date
  FROM ranked_orders
  WHERE order_rank = 1
)

SELECT
  o.customer_id,
  f.first_order_date,
  
  COUNT(DISTINCT CASE
    WHEN DATE_DIFF(o.order_date, f.first_order_date, DAY) BETWEEN 1 AND 10
    THEN o.order_id
  END) AS orders_within_10_days,
  
  COUNT(DISTINCT CASE
    WHEN DATE_DIFF(o.order_date, f.first_order_date, DAY) BETWEEN 1 AND 15
    THEN o.order_id
  END) AS orders_within_15_days,
  
  COUNT(DISTINCT CASE
    WHEN DATE_DIFF(o.order_date, f.first_order_date, DAY) BETWEEN 1 AND 20
    THEN o.order_id
  END) AS orders_within_20_days

FROM order_level as o

JOIN first_orders  as f
  ON o.customer_id = f.customer_id

GROUP BY
  o.customer_id,
  f.first_order_date

ORDER BY
  f.first_order_date,
  o.customer_id;



--- - 6. This one for BONUS: DAILY NEW CUSTOMER SHARE BY REPORTING CHANNEL ---
-- Extend Task 1 by breaking down daily new customer share ---
-- by marketing reporting channel ----

WITH order_level AS (
  SELECT DISTINCT
    o.order_id,
    o.customer_id,
    DATE(o.order_date) AS order_date,
    
    CASE
      WHEN ms.reporting_channel IS NULL OR TRIM(ms.reporting_channel) = '' THEN 'Unknown'
      ELSE ms.reporting_channel
    END AS reporting_channel
  
  FROM `koro-case-study-490117.koro_case.orders` o
  LEFT JOIN `koro-case-study-490117.koro_case.marketing_sources` ms
    ON o.order_id = ms.order_id
),
ranked_orders AS (
  SELECT
    order_id,
    customer_id,
    order_date,
    reporting_channel,
   
   ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY order_date, order_id
    ) AS order_rank
  FROM order_level
)

SELECT
  order_date,
  reporting_channel,
  
  COUNT(DISTINCT order_id) AS total_orders,
  
  COUNT(DISTINCT CASE WHEN order_rank = 1 THEN order_id END) AS first_time_orders,
  ROUND(
    100 * COUNT(DISTINCT CASE WHEN order_rank = 1 THEN order_id END)
      /   COUNT(DISTINCT order_id),2
  ) AS pct_orders_from_new_customers

FROM ranked_orders

  GROUP BY
  order_date,
  reporting_channel

  ORDER BY
  order_date,
  reporting_channel;


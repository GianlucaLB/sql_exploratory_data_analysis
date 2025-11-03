/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
  SELECT
    YEAR(f.order_date) AS order_year,
    p.product_name,
    SUM(f.sales_amount) AS current_sales
  FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p 
    ON f.product_key = p.product_key
  WHERE order_date IS NOT NULL
  GROUP BY YEAR(f.order_date), p.product_name
)

SELECT 
  order_year,
  product_name,
  current_sales,

  -- Calculate average yearly sales per product
  AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,

  -- Difference between current and average sales
  current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,

  -- Flag: indicates whether current sales are above/below/at average
  CASE 
    WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above AVG'
    WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below AVG'
    ELSE 'AVG'
  END AS avg_change,

  -- Previous year's sales per product
  LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,

  -- Difference from previous year's sales
  current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,

  -- Flag: indicates trend vs previous year
  CASE 
    WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
    WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
    ELSE 'No change'
  END AS py_change

FROM yearly_product_sales
ORDER BY product_name, order_year;
 

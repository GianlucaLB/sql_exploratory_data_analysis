--1) Base Query: Retrieves core columns from tables
WITH base_query AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ', c.last_name) customer_name,
DATEDIFF(year,c.birthdate, GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)
,
CTE_aggregations AS (
-- 2)Customer Aggregations: Summarizes key metrics at the customer level
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) as total_orders,
    SUM(sales_amount) as total_sales,
    SUM(quantity) as total_quantity,
    COUNT(DISTINCT product_key) as total_products,
    MAX(order_date) as last_order_date,
    DATEDIFF(Month,MIN(order_date),MAX(order_date)) lifespan
FROM base_query
GROUP By customer_key,customer_number,customer_name,age)
-- 3)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 and 29 THEN '20-29'
         WHEN age BETWEEN 30and 39 THEN '30-39'
         WHEN age BETWEEN 40and 49 THEN '40-49'
    Else '50 and above'
    END AS age_group,
   	CASE
		WHEN lifespan >= 12 AND total_sales> 5000 THEN 'Vip Customer'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular Customer'
		ELSE 'New Customer'
	END AS Customer_segment,
    last_order_date,
    DATEDIFF(month,last_order_date,GETDATE()) recency,
    total_orders,
    total_sales,
    total_products,
    lifespan,
    --Compute average order value (AVO)
    CASE WHEN total_orders = 0 THEN 0
   ELSE  total_sales/ total_orders
   END AS avg_order_value,
   --Compute average monthly spend
   CASE WHEN lifespan = 0 THEN total_sales
   ELSE    total_sales/ lifespan
   END AS  Avg_monthly_spend
FROM  CTE_aggregations

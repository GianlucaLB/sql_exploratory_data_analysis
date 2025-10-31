----Date Functions
SELECT
COUNT(DISTINCT customer_key) as total_customers,
Year(order_date) order_year,
MONTH(order_date) order_month,
sum(sales_amount) total_sales,
sum(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY Year(order_date) ,MONTH(order_date)
ORDER BY Year(order_date) ,MONTH(order_date) ;

----DATETRUNC()
SELECT
COUNT(DISTINCT customer_key) as total_customers,
DATETRUNC(MONTH,order_date) order_month,
sum(sales_amount) total_sales,
sum(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date) ;

----FORMAT()
SELECT
COUNT(DISTINCT customer_key) as total_customers,
format(order_date, 'yyyy-MMM') as order_date,
sum(sales_amount) total_sales,
sum(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY format(order_date, 'yyyy-MMM')
ORDER BY format(order_date, 'yyyy-MMM')

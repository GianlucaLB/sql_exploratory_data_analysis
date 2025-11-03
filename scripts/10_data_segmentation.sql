/* Group customers into three segments base on their spending behavior:
- VIP: Customers with at least 12 months of history and spending more than 5,000.
- Regular Customer with at least 12 months of history but spending 5,000 or less.
- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group */
WITH cte_customer_spending AS 
(
SELECT 
c.customer_key,
SUM(f.sales_amount) total_spending,
MIN(f.order_date) first_order,
MAX(f.order_date) last_order,
DATEDIFF(Month,MIN(f.order_date), MAX(f.order_date)) lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
Customer_segment,
COUNT(Customer_key) AS total_customers
FROM (
	SELECT
	customer_key,
	CASE
		WHEN lifespan >= 12 AND total_spending > 5000 THEN 'Vip Customer'
		WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular Customer'
		ELSE 'New Customer'
	END AS Customer_segment
	FROM cte_customer_spending) t
GROUP BY Customer_segment
ORDER BY total_customers DESC

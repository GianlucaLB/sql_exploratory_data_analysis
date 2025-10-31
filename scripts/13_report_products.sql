/*
===============================================================================
Product Report
===============================================================================

Purpose:
    Consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
         - total orders
         - total sales
         - total quantity sold
         - total customers (unique)
         - lifespan (in months)
    4. Calculates valuable KPIs:
         - recency (months since last sale)
         - average order revenue (AOR)
         - average monthly revenue
===============================================================================
*/


WITH cte_1 AS (
    /*------------------------------------------------------------------------------
    1) Retrieves core columns from fact_sales and dim_products
    ------------------------------------------------------------------------------*/
    SELECT
        f.customer_key,
        f.order_number,
        f.order_date,
        f.sales_amount,
        p.cost,
        f.quantity,
        f.product_key,
        p.product_name,
        p.category,
        p.sub_category
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),
 
cte_2 AS (
    /*------------------------------------------------------------------------------
    2) Aggregate product-level metrics
    ------------------------------------------------------------------------------*/
    SELECT
        product_key,
        product_name,
        category,
        sub_category,
        cost,
        COUNT(order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(cost) AS total_cost,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS avg_selling_price
    FROM cte_1
    GROUP BY product_key, product_name, category, sub_category, cost
)

SELECT 
    product_key,
    product_name,
    category,
    sub_category,
    cost,
    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
    
    /* Segment products by revenue */
    CASE 
        WHEN total_sales - total_cost > 50000 THEN 'High-Performers'
        WHEN total_sales - total_cost >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performers'
    END AS product_revenue,
    
    lifespan,
    total_orders,
    total_sales,
    total_cost,
    total_quantity,
    total_customers,
    avg_selling_price,
    
    /* Compute average order value (AOR) */
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders
    END AS avg_order_value,
    
    /* Compute average monthly spend */
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM cte_2
ORDER BY (total_sales - total_cost) DESC;

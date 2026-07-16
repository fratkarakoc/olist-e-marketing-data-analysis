-- MONTHLY SALES TREND

WITH month_price_cte AS (
	SELECT 
		o.order_id,
		o.order_status,
		o.order_purchase_timestamp,
		oi.price
	FROM orders AS o
	INNER JOIN order_items AS oi
	ON o.order_id = oi.order_id
	WHERE o.order_status IN ('delivered') AND o.order_purchase_timestamp >= '2017-01-01'
)
SELECT 
	TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS year_month,
	COUNT(DISTINCT(order_id)) AS recognized_orders,
	SUM(price) AS recognized_revenue,
	(SUM(price) - LAG(SUM(price))OVER(ORDER BY 
											TO_CHAR(order_purchase_timestamp, 'YYYY-MM') 
	)) AS revenue_change
FROM month_price_cte
GROUP BY year_month
ORDER BY year_month;

-- There seems to be an incline on the date of 2017-11. To see the reason for that we analyse the numbers day by day

WITH month_price_cte AS (
	SELECT 
		o.order_id,
		o.order_status,
		o.order_purchase_timestamp,
		oi.price
	FROM orders AS o
	INNER JOIN order_items AS oi
	ON o.order_id = oi.order_id
	WHERE 
		o.order_status IN ('delivered') AND
		o.order_purchase_timestamp >= '2017-11-01' AND
		o.order_purchase_timestamp <= '2017-12-01'
)
SELECT 
	DATE_TRUNC('day', order_purchase_timestamp) AS days,
	COUNT(DISTINCT(order_id)) AS recognized_orders,
	SUM(price) AS recognized_revenue
FROM month_price_cte
GROUP BY days
ORDER BY days;

-- It precisely inclines at the date of black friday (2017-11-24). That is an expected event.


-- REVENUE BY PRODUCT CATEGORY

WITH product_category_cte AS (
SELECT
	p.product_category_name,
	o.order_id,
	oi.price,
	o.order_status
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
LEFT JOIN products AS p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
)
SELECT 
	product_category_name AS category,
	SUM(price) AS revenue
FROM product_category_cte
GROUP BY category
ORDER BY revenue DESC;

-- REVENUE BY STATE

WITH state_revenue_cte AS
(SELECT 
	c.customer_id,
	o.order_id,
	c.customer_state,
	oi.price
FROM orders AS o
JOIN customers AS c 
	ON o.customer_id = c.customer_id
JOIN order_items AS oi
	ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
)
SELECT
	customer_state AS state,
	COUNT(DISTINCT(order_id)) AS orders,
	SUM(price) AS total_revenue
FROM state_revenue_cte
GROUP BY customer_state
ORDER BY total_revenue DESC;

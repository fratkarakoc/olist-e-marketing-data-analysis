-- Customer Satisfaction by Category

WITH category_review_cte AS (
	SELECT
		p.product_category_name,
		ore.review_score,
		ore.review_id
	FROM orders AS o
	INNER JOIN order_reviews AS ore 
		ON o.order_id = ore.order_id
	INNER JOIN order_items AS oi 
		ON o.order_id = oi.order_id
	INNER JOIN products AS p
		ON oi.product_id = p.product_id
	)
SELECT
	product_category_name AS category,
	ROUND(AVG(review_score),2) AS review_score_average_weighted
FROM category_review_cte
GROUP BY category
ORDER BY review_score_average_weighted DESC;


-- Review Scores Compared to Revenue Rank
-- This table shows the product categories with high revenue rate but relatively low review score average


WITH category_review_cte AS (
	SELECT 
		ore.review_id,
		ore.order_id,
		o.customer_id,
		oi.price,
		p.product_id,
		p.product_category_name,
		ore.review_score
	FROM orders AS o
	INNER JOIN order_reviews AS ore 
		ON o.order_id = ore.order_id
	INNER JOIN order_items AS oi 
		ON o.order_id = oi.order_id
	INNER JOIN products AS p
		ON oi.product_id = p.product_id
),
revenue_cte AS (
	SELECT
		product_category_name AS category,
		ROUND(AVG(review_score),2) AS weighted_average_review_score,
		SUM(price) AS revenue
	FROM category_review_cte
	GROUP BY product_category_name
),
revenue_rank_cte AS (
	SELECT 
		category,
		weighted_average_review_score,
		revenue,
		DENSE_RANK()OVER(
			ORDER BY revenue DESC) AS revenue_rank
	FROM revenue_cte
)
SELECT
	category,
	weighted_average_review_score,
	revenue,
	revenue_rank
FROM revenue_rank_cte
WHERE revenue_rank < 35 AND weighted_average_review_score < 3.5;

-- Categories by Review Count

WITH category_review_cte AS(
	SELECT 
		ore.review_id,
		ore.order_id,
		p.product_id,
		p.product_category_name,
		ore.review_score
	FROM orders AS o
	INNER JOIN order_reviews AS ore 
		ON o.order_id = ore.order_id
	INNER JOIN order_items AS oi 
		ON o.order_id = oi.order_id
	INNER JOIN products AS p
		ON oi.product_id = p.product_id
	)
SELECT
	product_category_name AS category,
	COUNT(DISTINCT(review_id)) AS item_review_count,
	ROUND(AVG(review_score),2) AS review_score_average
FROM category_review_cte
GROUP BY product_category_name
ORDER BY item_review_count DESC;


-- Sellers by Reviews

WITH seller_review_cte AS (
	SELECT
		oi.seller_id,
		ore.review_id
	FROM order_reviews AS ore
	INNER JOIN order_items AS oi
		ON ore.order_id = oi.order_id
	),
review_count_cte AS (
	SELECT
		seller_id,
		COUNT(DISTINCT(review_id)) AS review_count
	FROM seller_review_cte
	GROUP BY seller_id
	)
SELECT AVG(review_count)
FROM review_count_cte;
-- This shows that average review number that a seller get is 32


-- Average Review Scores of Sellers with More than 25 Reviews

WITH seller_review_cte AS (
	SELECT 
		ore.order_id,
		oi.seller_id,
		ore.review_id,
		ore.review_score
	FROM order_reviews AS ore
	INNER JOIN order_items AS oi
		ON ore.order_id = oi.order_id
)
SELECT
	seller_id,
	COUNT(DISTINCT(review_id)) AS review_count,
	ROUND(AVG(review_score),2) AS average_review_score
FROM seller_review_cte
GROUP BY seller_id
HAVING COUNT(DISTINCT(review_id)) > 25
ORDER BY average_review_score ASC;


-- Delivery Time's Effect on Customer Satisfaction


WITH review_delivery_cte AS(
	SELECT
		o.order_id,
		ore.review_id,
		ore.review_score,
		ore.review_creation_date,
		o.order_purchase_timestamp AS purchase_date,
		o.order_delivered_carrier_date AS shipping_date,
		o.order_delivered_customer_date AS delivery_date,
		o.order_estimated_delivery_date AS estimated_delivery
	FROM order_reviews AS ore
	INNER JOIN orders AS o
		ON o.order_id = ore.order_id
	WHERE o.order_delivered_carrier_date IS NOT NULL
	)
SELECT
	AVG(shipping_date - purchase_date)
FROM review_delivery_cte;
-- This query shows average time to ship a delivery is around 2 days



WITH review_delivery_cte AS(
	SELECT
		o.order_id,
		ore.review_id,
		ore.review_score,
		ore.review_creation_date,
		o.order_purchase_timestamp AS purchase_date,
		o.order_delivered_carrier_date AS shipping_date,
		o.order_delivered_customer_date AS delivery_date,
		o.order_estimated_delivery_date AS estimated_delivery
	FROM order_reviews AS ore
	INNER JOIN orders AS o
		ON o.order_id = ore.order_id
	WHERE o.order_delivered_carrier_date IS NOT NULL
	)
SELECT
	(delivery_date - purchase_date) AS delivery_time,
	(estimated_delivery - purchase_date) AS estimated_delivery_time,
	review_score,
	order_id
FROM review_delivery_cte
WHERE 
	(estimated_delivery - purchase_date) < (delivery_date - purchase_date);
-- This table lets us see how a late delivery effects the review score


SELECT 
	ROUND(AVG(average_review),2)
FROM  (SELECT
	oi.seller_id,
	AVG(ore.review_score) AS average_review
FROM order_items AS oi
INNER JOIN order_reviews AS ore
	ON oi.order_id = ore.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT(ore.review_id)) > 10);

-- This query shows that a seller with higher than 10 reviews gets review score of 4 on average



WITH review_delivery_cte AS(
	SELECT
		o.order_id,
		ore.review_id,
		ore.review_score,
		ore.review_creation_date,
		oi.seller_id,
		o.order_purchase_timestamp AS purchase_date,
		o.order_delivered_carrier_date AS shipping_date,
		o.order_delivered_customer_date AS delivery_date,
		o.order_estimated_delivery_date AS estimated_delivery
	FROM order_reviews AS ore
	INNER JOIN orders AS o
		ON o.order_id = ore.order_id
	INNER JOIN order_items AS oi
		ON o.order_id = oi.order_id
	WHERE o.order_delivered_carrier_date IS NOT NULL
	), 
delivery_time_cte AS(
	SELECT
		seller_id,
		review_id,
		(delivery_date - purchase_date) AS delivery_time,
		(estimated_delivery - purchase_date) AS estimated_delivery_time,
		review_score
	FROM review_delivery_cte
	WHERE 
		(estimated_delivery - purchase_date) < (delivery_date - purchase_date)
	)
SELECT 
	seller_id,
	COUNT(DISTINCT(review_id)),
	AVG(delivery_time - estimated_delivery_time) AS latency,
	ROUND(AVG(review_score),2) AS weighted_review_score_average
FROM delivery_time_cte
GROUP BY seller_id
HAVING COUNT(DISTINCT(review_id)) > 10

-- Another look at how delivery latency effects the review score. Sellers with  higher latencies tend to have lower review score averages





	
	
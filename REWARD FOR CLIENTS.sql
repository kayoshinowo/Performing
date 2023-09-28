USE WAREHOUSE

-- Day 43 (Common Table Expression)
/*CASE STUDY: A retail store looking to create a reward system for its loyal clients and also remove some product from 
the shelf hire you to extract some vital information from their database, the query below is the provided dataset*/
USE sales_db;
SELECT * FROM sales;
SELECT * FROM customers;

-- Return the Each Product's top patronizing customer
WITH top_customer_per_product_cte AS(
		SELECT c.customer_name, p.product_name, SUM(s.revenue) AS order_value,
				DENSE_RANK() OVER(PARTITION BY p.product_name ORDER BY SUM(s.revenue) DESC, c.customer_name ASC) AS revenue_rank
		FROM customers c
		JOIN sales s
		ON c.customer_id = s.customer_id
		JOIN products p 
		ON s.product_id = p.product_id
		GROUP BY c.customer_name, p.product_name
        )
SELECT customer_name, product_name, order_value
FROM top_customer_per_product_cte
WHERE revenue_rank =1
ORDER BY customer_name;

-- From the query above return  the elite of the top customers 
-- (i.e. customers who top procurement list in multiple products)
WITH top_customer_per_product_cte AS(
		SELECT c.customer_name, p.product_name, SUM(s.revenue) AS order_value,
				DENSE_RANK() OVER(PARTITION BY p.product_name ORDER BY SUM(s.revenue) DESC, c.customer_name ASC) AS revenue_rank
		FROM customers c
		JOIN sales s
		ON c.customer_id = s.customer_id
		JOIN products p 
		ON s.product_id = p.product_id
		GROUP BY c.customer_name, p.product_name
        ) 
SELECT customer_name, COUNT(*) AS num_of_products, SUM(order_value) AS total_spent
FROM top_customer_per_product_cte
WHERE revenue_rank =1
GROUP BY customer_name
HAVING COUNT(*) > 1
ORDER BY total_spent DESC;

-- Retrieve the list of products that perform poorly compare to the previous quarter of 2017 calendar year
WITH prod_qoq_cte AS (
		SELECT p.product_name, QUARTER(s.order_date) AS qoy, SUM(s.revenue) AS total_revenue,
				LAG(SUM(s.revenue), 1, 0) OVER(PARTITION BY p.product_name ORDER BY QUARTER(s.order_date)) AS prev_quart_rev,
				ROUND(100.00 * (SUM(s.revenue)/(LAG(SUM(s.revenue), 1, 0) 
							OVER(PARTITION BY p.product_name ORDER BY QUARTER(s.order_date)))-1),2) AS qoq_rev_change
		FROM products p
        JOIN sales s
        ON p.product_id = s.product_id
        WHERE YEAR(s.order_date) = 2017
		GROUP BY QUARTER(s.order_date), p.product_name
		ORDER BY p.product_name, qoy) 
SELECT * 
FROM prod_qoq_cte
WHERE qoq_rev_change < 0
ORDER BY qoq_rev_change ASC;
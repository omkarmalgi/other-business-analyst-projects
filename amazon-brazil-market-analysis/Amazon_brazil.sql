------------------------------------------------------
--Customer Data
------------------------------------------------------
CREATE TABLE amazon_brazil.customer_data (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(10) NOT NULL
);
------------------------------------------------------
--Order Items
------------------------------------------------------
CREATE TABLE amazon_brazil.order_items (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date TIMESTAMP NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    freight_value NUMERIC(10,2) NOT NULL,

    PRIMARY KEY (order_id, order_item_id)
);
------------------------------------------------------
--Payments
------------------------------------------------------
CREATE TABLE amazon_brazil.payments (
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value NUMERIC(10,2) NOT NULL,

    PRIMARY KEY (order_id, payment_sequential)
);
------------------------------------------------------
--Orders
------------------------------------------------------
CREATE TABLE amazon_brazil.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP NOT NULL
);
------------------------------------------------------
--Product
------------------------------------------------------
CREATE TABLE amazon_brazil.product (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);
------------------------------------------------------
--Sellers
------------------------------------------------------
CREATE TABLE amazon_brazil.sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10) NOT NULL
);
--------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------ANALYSIS - I----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
/*QUE 1 - To simplify its financial reports, Amazon India needs to standardize payment values. 
Round the average payment values to integer (no decimal) for each payment type and display the results sorted in ascending order.*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT payment_type, ROUND(AVG(payment_value)) AS avg_payment_value
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY avg_payment_value ASC

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 2 - To refine its payment strategy, Amazon India wants to know the distribution of orders by payment type. 
Calculate the percentage of total orders for each payment type, rounded to one decimal place, and display them in descending order*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT payment_type, ROUND(COUNT(payment_type)*100/SUM(COUNT(*)) OVER(), 1) AS percentage_total
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY percentage_total DESC

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 3 - Amazon India seeks to create targeted promotions for products within specific price ranges. Identify all products priced 
between 100 and 500 BRL that contain the word 'Smart' in their name. Display these products, sorted by price in descending order.*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT o.product_id, o.price, p.product_category_name
FROM amazon_brazil.order_items o
JOIN amazon_brazil.product p
ON p.product_id = o.product_id
WHERE o.price BETWEEN 100 AND 500
AND p.product_category_name ILIKE '%smart%'
ORDER BY o.price DESC

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 4 - To identify seasonal sales patterns, Amazon India needs to focus on the most successful months. Determine the top 3 months 
with the highest total sales value, rounded to the nearest integer.*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
ROUND(SUM(oi.price)) AS total_sales
FROM amazon_brazil.orders o
JOIN amazon_brazil.order_items oi
ON oi.order_id = o.order_id
GROUP BY month
ORDER BY total_sales DESC
LIMIT 3

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 5 - Amazon India is interested in product categories with significant price variations. Find categories where the 
difference between the maximum and minimum product prices is greater than 500 BRL.*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT p.product_category_name, 
   MAX(o.price) - MIN(o.price) AS price_difference
FROM amazon_brazil.product p
JOIN amazon_brazil.order_items o
ON o.product_id = p.product_id
GROUP BY p.product_category_name
HAVING (MAX(o.price) - MIN(o.price)) > 500

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 6 - To enhance the customer experience, Amazon India wants to find which payment types have the most consistent transaction 
amounts. Identify the payment types with the least variance in transaction amounts, sorting by the smallest standard deviation first.*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT payment_type, STDDEV(payment_value) AS standard_deviation
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY standard_deviation

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 7 - Amazon India wants to identify products that may have incomplete name in order to fix it from their end. Retrieve 
the list of products where the product category name is missing or contains only a single character.*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT product_id, product_category_name
FROM amazon_brazil.product
WHERE product_category_name IS NULL
OR LENGTH(product_category_name)=1

--------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------ANALYSIS - II--------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
/*QUE 1 - Amazon India wants to understand which payment types are most popular across different order value segments (e.g., low, 
medium, high). Segment order values into three ranges: orders less than 200 BRL, between 200 and 1000 BRL, and over 1000 BRL. 
Calculate the count of each payment type within these ranges and display the results in descending order of count*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT 
   (CASE 
   WHEN payment_value < 200 THEN 'LOW'
   WHEN payment_value BETWEEN 200 AND 1000 THEN 'MEDIUM'
   ELSE 'HIGH'
   END) AS order_value_segment, 
   payment_type, COUNT(payment_type) AS count
FROM amazon_brazil.payments
GROUP BY order_value_segment, payment_type
ORDER BY count DESC

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 2 - Amazon India wants to analyse the price range and average price for each product category. Calculate the minimum, maximum, 
and average price for each category, and list them in descending order by the average price.*/
--------------------------------------------------------------------------------------------------------------------------------------
SELECT p.product_category_name, 
       MIN(o.price) AS min_price,
	   MAX(o.price) AS max_price,
	   ROUND(AVG(o.price), 2) AS avg_price
FROM amazon_brazil.product p
JOIN amazon_brazil.order_items o
ON o.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_price DESC	  

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 3 - Amazon India wants to identify the customers who have placed multiple orders over time. Find all customers with more than 
one order, and display their customer unique IDs along with the total number of orders they have placed.*/	  
--------------------------------------------------------------------------------------------------------------------------------------	   
SELECT c.customer_unique_id, 
	COUNT(o.order_id) AS total_orders
FROM amazon_brazil.customer_data c
JOIN amazon_brazil.orders o
ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id)>1

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 4 - Amazon India wants to categorize customers into different types ('New – order qty. = 1' ;  'Returning' –order qty. 2 to 4;  
'Loyal' – order qty. >4) based on their purchase history. Use a temporary table to define these categories and join it with the 
customers table to update and display the customer types.*/
--------------------------------------------------------------------------------------------------------------------------------------
CREATE TEMP TABLE customer_types AS
SELECT c.customer_unique_id,
    (CASE
     WHEN COUNT(o.order_id) = 1 THEN 'New'
     WHEN COUNT(o.order_id) BETWEEN 2 AND 4 THEN 'Returning'
     ELSE 'Loyal'
    END) AS customer_type
FROM amazon_brazil.customer_data c
JOIN amazon_brazil.orders o
ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;

SELECT
    c.customer_unique_id,
    ct.customer_type
FROM amazon_brazil.customer_data c
JOIN customer_types ct
ON c.customer_unique_id = ct.customer_unique_id;

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 5 - Amazon India wants to know which product categories generate the most revenue. Use joins between the tables to calculate the 
total revenue for each product category. Display the top 5 categories.*/	
--------------------------------------------------------------------------------------------------------------------------------------
SELECT p.product_category_name, 
	   SUM(o.price) AS total_revenue
FROM amazon_brazil.product p
JOIN amazon_brazil.order_items o
ON o.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5

--------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------ANALYSIS - III--------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
/*Que 1 - The marketing team wants to compare the total sales between different seasons. Use a "subquery" to calculate total sales for 
each season (Spring, Summer, Autumn, Winter) based on order purchase dates, and display the results. Spring is in the months of March, 
April and May. Summer is from June to August and Autumn is between September and November and rest months are Winter. */
--------------------------------------------------------------------------------------------------------------------------------------
SELECT season, SUM(price) AS total_sales
FROM (SELECT
        CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (6, 7, 8) THEN 'Summer'
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (9, 10, 11) THEN 'Autumn'
        ELSE 'Winter'
        END AS season,
        oi.price AS price
    FROM amazon_brazil.orders o
    JOIN amazon_brazil.order_items oi
    ON o.order_id = oi.order_id) AS sales_data
GROUP BY season;

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 2 - The inventory team is interested in identifying products that have sales volumes above the overall average. Write a query 
that uses a subquery to filter products with a total quantity sold above the average quantity.*/	
--------------------------------------------------------------------------------------------------------------------------------------
SELECT product_id, 
	COUNT(order_item_id) AS total_quantity_sold
FROM amazon_brazil.order_items
GROUP BY product_id
HAVING COUNT(order_item_id)> (SELECT AVG(total_quantity_sold)
    						  FROM (SELECT product_id,
										        COUNT(order_item_id) AS total_quantity_sold
										        FROM amazon_brazil.order_items
										        GROUP BY product_id ))

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 3 - To understand seasonal sales patterns, the finance team is analysing the monthly revenue trends over the past year 
(year 2018). Run a query to calculate total revenue generated each month and identify periods of peak and low sales. Export the 
data to Excel and create a graph to visually represent revenue changes across the months. */
--------------------------------------------------------------------------------------------------------------------------------------
SELECT EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
		SUM(oi.price) AS total_revenue
FROM amazon_brazil.order_items oi
JOIN amazon_brazil.orders o
ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY month
ORDER BY month

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 4 - A loyalty program is being designed  for Amazon India. Create a segmentation based on purchase frequency: ‘Occasional’ for 
customers with 1-2 orders, ‘Regular’ for 3-5 orders, and ‘Loyal’ for more than 5 orders. Use a CTE to classify customers and their 
count and generate a chart in Excel to show the proportion of each segment.*/	
--------------------------------------------------------------------------------------------------------------------------------------
WITH customer_orders AS(
SELECT customer_id, COUNT(order_id) AS order_count
FROM amazon_brazil.orders
GROUP BY customer_id
),

customer_segments AS(
SELECT customer_id, 
	CASE WHEN order_count BETWEEN 1 AND 2 THEN 'Occasional'
	     WHEN order_count BETWEEN 3 AND 5 THEN 'Regular'
		 ELSE 'Loyal'
		 END AS customer_type
FROM customer_orders)

SELECT customer_type, COUNT(*) AS count
FROM customer_segments
GROUP BY customer_type

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 5 - Amazon wants to identify high-value customers to target for an exclusive rewards program. You are required to rank customers 
based on their average order value (avg_order_value) to find the top 20 customers.*/	
--------------------------------------------------------------------------------------------------------------------------------------
WITH order_values AS(
SELECT order_id, SUM(price) AS order_value
FROM amazon_brazil.order_items
GROUP BY order_id),

customer_avg AS(
SELECT o.customer_id, AVG(ov.order_value) AS avg_order_value
FROM amazon_brazil.orders o
JOIN order_values ov
ON o.order_id = ov.order_id
GROUP BY o.customer_id)

SELECT customer_id, avg_order_value,
RANK() OVER(ORDER BY avg_order_value DESC) AS customer_rank
FROM customer_avg
ORDER BY customer_rank
LIMIT 20

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 6 - Amazon wants to analyze sales growth trends for its key products over their lifecycle. Calculate monthly cumulative sales 
for each product from the date of its first sale. Use a recursive CTE to compute the cumulative sales (total_sales) for each product 
month by month.*/	
--------------------------------------------------------------------------------------------------------------------------------------
WITH RECURSIVE monthly_sales AS (
SELECT oi.product_id,
       DATE_TRUNC('month', o.order_purchase_timestamp)::date AS sale_month,
       SUM(oi.price) AS monthly_sales
FROM amazon_brazil.orders o
JOIN amazon_brazil.order_items oi
ON o.order_id = oi.order_id
GROUP BY oi.product_id, DATE_TRUNC('month', o.order_purchase_timestamp)),

numbered_sales AS (
SELECT product_id, sale_month, monthly_sales,
       ROW_NUMBER() OVER (PARTITION BY product_id
            			  ORDER BY sale_month) AS month_no
FROM monthly_sales),

cumulative_sales AS (
SELECT product_id, sale_month, month_no, monthly_sales AS total_sales
FROM numbered_sales
WHERE month_no = 1

UNION ALL

SELECT n.product_id, n.sale_month, n.month_no,
        c.total_sales + n.monthly_sales AS total_sales
FROM cumulative_sales c
JOIN numbered_sales n
ON c.product_id = n.product_id
AND n.month_no = c.month_no + 1)

SELECT product_id, sale_month, total_sales
FROM cumulative_sales
ORDER BY product_id, sale_month;

--------------------------------------------------------------------------------------------------------------------------------------
/*Que 7 - To understand how different payment methods affect monthly sales growth, Amazon wants to compute the total sales for each 
payment method and calculate the month-over-month growth rate for the past year (year 2018). Write query to first calculate total 
monthly sales for each payment method, then compute the percentage change from the previous month.*/	
--------------------------------------------------------------------------------------------------------------------------------------
WITH monthly_sales AS (
SELECT p.payment_type, DATE_TRUNC('month', o.order_purchase_timestamp)::date AS sale_month,
       SUM(p.payment_value) AS monthly_total
FROM amazon_brazil.orders o
JOIN amazon_brazil.payments p
ON o.order_id = p.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY p.payment_type, DATE_TRUNC('month', o.order_purchase_timestamp)),

sales_with_previous AS (
SELECT payment_type, sale_month, monthly_total,
        LAG(monthly_total) OVER (PARTITION BY payment_type
                                  ORDER BY sale_month) AS previous_month
FROM monthly_sales)

SELECT payment_type, sale_month, monthly_total,
    ROUND(((monthly_total - previous_month) / NULLIF(previous_month, 0)) * 100,2) AS monthly_change
FROM sales_with_previous
ORDER BY payment_type, sale_month

--------------------------------------------------------------------------------------------------------------------------------------





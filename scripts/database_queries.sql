			--SQL FUNCTIONS--

''' WINDOW FUNCTIONS '''

--1. Total sales amount for each order along with the individual product sales.
SELECT 
	o.order_id,
	p.product_id,
	p.price,
	o.quantity,
	o.total_price,
	SUM(p.price * o.quantity) OVER (PARTITION BY o.order_id) AS total_sales_amount
FROM
	yanki.orders o
JOIN
	yanki.products p ON o.product_id = p.product_id;

-- The windows function applies SUM function to each order


-- 2.The running total price or running cost for each order.

SELECT 
	order_id,
	product_id,
	quantity,
	total_price,
	SUM(total_price) OVER (ORDER BY order_id) AS running_total_cost
	
FROM 
	yanki.orders;


-- 3. Rank products by their price within each category.

SELECT
	product_id,
	product_name,
	brand,
	category,
	price,
	RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank_by_category
FROM
	yanki.products;
	
''' RANKING OPERATIONS '''

--1. Rank customers by the total amount they have spent.

SELECT 
	c.customer_id,
	c.customer_name,
	SUM(total_price) AS total_spent,
	RANK() OVER (ORDER BY SUM(total_price) DESC) AS customer_rank
FROM
	yanki.customers c
JOIN
	yanki.orders o ON c.customer_id = o.customer_id
GROUP BY
	c.customer_id,
	c.customer_name;


--2. Rank products by their total sales amount. 

SELECT
	p.product_id,
	p.product_name,
	SUM(quantity) AS total_quantity_sold,
	SUM(total_price) as total_sales_amount,
	RANK() OVER (ORDER BY SUM(total_price) DESC) AS product_rank
FROM
	yanki.products p
JOIN
	yanki.orders o ON p.product_id = o.product_id
GROUP BY
	p.product_id,
	p.product_name;

--3. Rank orders by their total price.

SELECT 
	order_id,
	total_price,
	RANK() OVER (ORDER BY total_price DESC) AS total_price_rank
FROM
	yanki.orders;


''' CASE FUNCTIONS '''

--1.Categorize the orders based on the total price.
SELECT
	order_id,
	total_price,
	CASE
		WHEN total_price >= 1000 THEN 'High spending'
		WHEN total_price >= 500 THEN 'Medium spending'
		ELSE 'Low Spending'
	END AS total_price_category
FROM
	yanki.orders

--2. Classify customers by the number of orders they made.

SELECT 
	c.customer_id,
	c.customer_name,
	COUNT(order_id) as number_of_orders,
	CASE
		WHEN COUNT(order_id) >=10 THEN 'FREQUENT'
		WHEN COUNT(order_id) >=5 AND COUNT(order_id) <10 THEN 'REGULAR'
		ELSE 'OCCASIONAL'
	END AS order_frequency
FROM
	yanki.customers c
JOIN
	yanki.orders o ON o.customer_id = c.customer_id
GROUP BY
	c.customer_id,
	c.customer_name;

--3.Classify products by their prices.

SELECT
	product_id,
	product_name,
	price,
	CASE
		WHEN price >= 500 THEN 'Expensive'
		WHEN price >= 100 AND price <500 THEN 'Moderate'
		ELSE 'Affordable'
	END AS price_category
FROM
	yanki.products;
	
	
''' JOINS'''
-- Inner Joins
--1. Retreive customer details along with the products they ordered.

SELECT 
	c.customer_id,
	c.customer_name,
	c.email,
	c.phone_number,
	o.order_id,
	p.product_id,
	p.product_name,
	p.price,
	p.brand,
	p.category,
	o.quantity,
	o.total_price
FROM 
	yanki.customers c
INNER JOIN
	yanki.orders o ON c.customer_id = o.customer_id
INNER JOIN
	yanki.products p ON o.product_id = p.product_id;
	
	
--2. Retreive order details along with payment information

SELECT 
	o.order_id,
	o.product_id,
	pm.payment_method,
	pm.transaction_status
FROM 
	yanki.orders o
INNER JOIN
	yanki.payment_method pm ON o.order_id = pm.order_id;


-- Left Join
--1. Retreive all customers along with their orders, even if they haven't placed any orders

SELECT
	c.customer_id,
	c.customer_name,
	c.email,
	c.phone_number,
	o.order_id,
	o.quantity,
	o.total_price
FROM
	yanki.customers c
LEFT JOIN
	yanki.orders o ON c.customer_id = o.customer_id;

--2. Retreive all orders with product details, even if there are no corresponding products

SELECT
	o.order_id,
	o.customer_id,
	p.product_id,
	p.product_name,
	p.price,
	o.quantity,
	o.total_price
FROM
	yanki.orders o
LEFT JOIN
	yanki.products p ON o.product_id = p.product_id;


-- Right Join
--1.Retreive all orders along with payment information, even if there are no corresponding payment records
SELECT 
	o.order_id,
	pm.payment_method,
	pm.transaction_status
FROM 
	yanki.orders o
RIGHT JOIN
	yanki.payment_method pm ON o.order_id = pm.order_id;


--2.Retreive all products along with others, even if there are no corresponding orders
SELECT
	p.product_id,
	p.product_name,
	o.order_id,
	o.quantity,
	o.total_price
FROM
	yanki.products p
LEFT JOIN
	yanki.orders o ON p.product_id = o.product_id;

-- Outer Join
--1.Retreive all customers along with their orders, including customers who have not placed anu orders, and all orders without corresponding customers
SELECT
	c.customer_id,
	c.customer_name,
	c.email,
	c.phone_number,
	o.order_id,
	o.quantity,
	o.total_price
FROM
	yanki.customers c
FULL OUTER JOIN
	yanki.orders o ON c.customer_id = o.customer_id;

--2.Retrieve all orders along with payment information, including orders without corresponding
-- payment records and payment records without corresponding orders

SELECT 
	o.order_id,
	pm.payment_method,
	pm.transaction_status
FROM 
	yanki.orders o
FULL OUTER JOIN
	yanki.payment_method pm ON o.order_id = pm.order_id;


''' INDEXING'''
CREATE INDEX idx_orders_customer_id ON yanki.orders (customer_id);
CREATE INDEX idx_orders_product_id ON yanki.orders (product_id);
CREATE INDEX idx_orders_order_date ON yanki.orders (order_date);
CREATE INDEX idx_payment_method_order_id ON yanki.payment_method (order_id);
CREATE INDEX idx_shipping_address_customer_id ON yanki.shipping_address (customer_id);
CREATE INDEX idx_products_category ON yanki.products (category);

-- Composite Indexes
CREATE INDEX idx_orders_customer_id_order_date ON yanki.orders (customer_id, order_date);

/*
Indexing improves query speed and performance especially for large datasets and frequently run queries
Indexes are powerful tools for optimizing database performance. 
They are particularly effective for improving query speed, enforcing uniqueness, and enhancing join operations. 
However, they should be used judiciously, considering the trade-offs in terms of storage and write performance.

-- Composite Indexes can be useful if you have queries that filter or sort based on multiple columns, composite indexes can be beneficial
    -- Foreign Key Indexes: Essential for efficient joins.
    -- Composite Indexes: Useful for queries that involve filtering or sorting by multiple columns.
*/
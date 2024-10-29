-- Create the customers table to store customer details.
CREATE TABLE customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50) NOT NULL,
    email NVARCHAR(50) NOT NULL UNIQUE,
    city NVARCHAR(50),
    join_date DATE
);

-- Create the products table to store product information.
CREATE TABLE products (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT
);

-- Create the orders table to store order records with foreign key reference to customers.
CREATE TABLE orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create the order_items table to link orders with products and track quantity and total for each item.
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT,
    product_id INT,
    quantity INT,
    item_total DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample data into customers table.
INSERT INTO customers (name, email, city, join_date) VALUES
('Alice', 'alice@example.com', 'New York', '2023-01-01'),
('Bob', 'bob@example.com', 'Los Angeles', '2023-01-02'),
('Carol', 'carol@example.com', 'Chicago', '2023-01-03');

-- Insert sample data into products table.
INSERT INTO products (name, price, stock) VALUES
('Laptop', 1200.00, 10),
('Smartphone', 800.00, 15),
('Tablet', 300.00, 25);

-- Insert sample data into orders table with references to customer IDs.
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2023-01-10', 2000.00),
(2, '2023-01-12', 800.00);

-- Insert sample data into order_items table to link orders with specific products and quantities.
INSERT INTO order_items (order_id, product_id, quantity, item_total) VALUES
(1, 1, 1, 1200.00),
(1, 3, 2, 600.00),
(2, 2, 1, 800.00);

-- Retrieve all customer information.
SELECT * FROM customers;

-- Retrieve all orders made by customer with customer_id = 1.
SELECT * FROM orders
WHERE customer_id = 1;

-- Join orders, customers, order_items, and products tables to get detailed order information.
SELECT orders.order_id, customers.name AS customer_name, products.name AS product_name,
       order_items.quantity, order_items.item_total
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id
JOIN order_items ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id;

-- Calculate the total sales for each product by summing item_totals.
SELECT products.name AS product_name, 
       SUM(order_items.item_total) AS total_sales
FROM order_items
JOIN products ON order_items.product_id = products.product_id
GROUP BY products.name;

-- Retrieve the top 5 customers by total spending, ordered from highest to lowest.
SELECT TOP 5 customers.name, 
       SUM(orders.total_amount) AS total_spent
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.name
ORDER BY total_spent DESC;

-- Update the stock of a product by subtracting the quantity ordered from the stock count for product_id = 1.
UPDATE products
SET stock = stock - (SELECT quantity FROM order_items WHERE product_id = products.product_id)
WHERE product_id = 1;

-- Create an index on customer_id column in the orders table to optimize queries that filter by customer_id.
CREATE INDEX idx_customer_id ON orders (customer_id);

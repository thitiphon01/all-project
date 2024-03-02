-- Items table
CREATE TABLE Items (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(255),
    price DECIMAL(10, 2),
    invoice_id INT,
    FOREIGN KEY (invoice_id) REFERENCES Invoices(invoice_id)
);

INSERT INTO Items (item_id, item_name, price, invoice_id)
VALUES
    (1, 'Coffee', 3.50, 1),
    (2, 'Tea', 2.50, 1),
    (3, 'Croissant', 2.00, 2),
    (4, 'Sandwich', 5.50, 2),
    (5, 'Cake', 4.00, 3),
    (6, 'Salad', 6.50, 3),
    (7, 'Smoothie', 4.50, 4),
    (8, 'Muffin', 2.50, 4),
    (9, 'Bagel', 3.00, 5),
    (10, 'Soup', 4.50, 5);

-- Invoices table
CREATE TABLE Invoices (
    invoice_id INT PRIMARY KEY,
    order_date DATETIME,
    customer_id INT,
    item_id INT,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES Items(item_id)
);

INSERT INTO Invoices (invoice_id, order_date, customer_id, item_id, quantity)
VALUES
    (1, '2023-01-01 08:30:00', 1, 1, 2),
    (2, '2023-01-02 12:45:00', 2, 3, 1),
    (3, '2023-01-03 10:15:00', 3, 5, 3),
    (4, '2023-01-04 09:00:00', 4, 2, 1),
    (5, '2023-01-05 11:30:00', 5, 4, 2),
    (6, '2023-01-06 14:00:00', 1, 6, 1),
    (7, '2023-01-07 16:45:00', 2, 8, 3),
    (8, '2023-01-08 13:20:00', 3, 10, 2),
    (9, '2023-01-09 18:00:00', 4, 7, 1),
    (10, '2023-01-10 20:30:00', 5, 9, 2),
    (11, '2023-01-11 11:15:00', 6, 5, 1),
    (12, '2023-01-12 15:00:00', 7, 4, 3),
    (13, '2023-01-13 17:45:00', 8, 3, 2),
    (14, '2023-01-14 14:30:00', 9, 1, 1),
    (15, '2023-01-15 10:00:00', 10, 2, 2),
    (16, '2023-01-16 12:45:00', 1, 8, 1),
    (17, '2023-01-17 09:30:00', 2, 6, 3),
    (18, '2023-01-18 14:15:00', 3, 9, 2),
    (19, '2023-01-19 16:00:00', 4, 7, 1),
    (20, '2023-01-20 11:45:00', 5, 10, 2);

-- Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    email VARCHAR(255),
    birthdate DATE,
    member_date DATE
);

INSERT INTO Customers (customer_id, email, birthdate, member_date)
VALUES
    (1, 'customer1@example.com', '1990-01-15', '2022-01-01'),
    (2, 'customer2@example.com', '1985-05-20', '2022-02-05'),
    (3, 'customer3@example.com', '1988-08-10', '2022-03-10'),
    (4, 'customer4@example.com', '1995-03-25', '2022-04-15'),
    (5, 'customer5@example.com', '1980-12-05', '2022-05-20'),
    (6, 'customer6@example.com', '1993-09-18', '2022-06-25'),
    (7, 'customer7@example.com', '1987-06-30', '2022-07-30'),
    (8, 'customer8@example.com', '1994-02-14', '2022-08-05'),
    (9, 'customer9@example.com', '1982-04-22', '2022-09-10'),
    (10, 'customer10@example.com', '1998-07-08', '2022-10-15');

-- RUN PREVIEW
.print \n Items table
.mode box
select * from Items limit 5;

.print \n Invoices table
.mode box
select * from Invoices limit 5;

.print \n Customers table
.mode box
select * from Customers limit 5;


-- Analysing the data and finding the most popular items
-- 1. Find the total sales of each product order by item_id
SELECT 
  i.item_id,
  i.item_name,
  SUM(i.price * inv.quantity) total_sales
FROM 
  Items i 
JOIN
  Invoices inv ON i.item_id = inv.item_id
GROUP BY
  i.item_id, i.item_name
ORDER BY
  i.item_id;

-- 2. Find each customer's cumulative sales from highest to lowest of cumulative sales
SELECT
  c.customer_id,
  c.email, 
  SUM(i.price * inv.quantity) cumulative_sales
FROM
  Customers c
JOIN
  Invoices inv ON c.customer_id = inv.customer_id
JOIN 
  Items i on inv.item_id = i.item_id
GROUP BY 
  c.customer_id, c.email
ORDER BY 
  cumulative_sales DESC;
 -- 3. Classification about the products as Dairy Products or Non-Dairy Products ?
SELECT
    item_id,
    item_name,
    price,
    invoice_id,
CASE
    WHEN item_id IN (3, 4, 5, 8, 9) THEN 'Dairy Product'
ELSE 'Non-Dairy Product'
    END AS product_category
FROM
    Items;
-- 4.  Find sales of Daily Product, Non-Dairy Product and proportion of sales of both products ?
WITH ProductCategories AS (
  SELECT 
    i.item_id, 
    i.item_name,
    CASE 
      WHEN item_id IN (3, 4, 5, 8, 9) THEN 'Dairy Product'
      ELSE 'Non-Dairy Product'
    END AS product_category
  FROM 
    Items i
)
SELECT 
  pc.product_category,
  SUM(inv.quantity) total_quantity_sold, 
  (SUM(inv.quantity)*100 / (SELECT SUM(quantity) FROM Invoices)) percentage_sold
FROM 
  ProductCategories pc
JOIN
  Invoices inv ON pc.item_id = inv.item_id
GROUP BY 
  pc.product_category;
-- 5. Find totals of sales for each day of the week ? 
SELECT 
  strftime('%w', order_date) day_of_week,
  SUM(i.price * inv.quantity) total_sold
FROM
  Invoices inv
JOIN 
  Items i ON inv.item_id = i.item_id
GROUP BY
  day_of_week
ORDER BY 
  day_of_week;

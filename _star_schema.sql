create table sales_data(
		Order_Date date,
		Customer_Name varchar (20),
		Category varchar (20),
		Region varchar (20),
		Quantity int,
		Sales decimal (10,2),
		Profit decimal (10,2)
		
);

select * from sales_data;


--CREATE DIMENSION TABLES--

--1️⃣ Customer Dimension
CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100)
);

--2️⃣ Product Dimension (Category)
CREATE TABLE dim_product (
    product_id SERIAL PRIMARY KEY,
    category VARCHAR(50)
);

--3️⃣ Region Dimension
CREATE TABLE dim_region (
    region_id SERIAL PRIMARY KEY,
    region VARCHAR(50)
);

--4️⃣ Date Dimension
CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    order_date DATE,
    year INT,
    month INT
);


--INSERT DATA INTO DIMENSION TABLES--


--Customer
INSERT INTO dim_customer (customer_name)
SELECT DISTINCT Customer_Name
FROM sales_data;

--Product (Category)
INSERT INTO dim_product (category)
SELECT DISTINCT Category
FROM sales_data;

--Region
INSERT INTO dim_region (region)
SELECT DISTINCT Region
FROM sales_data;

--Date
INSERT INTO dim_date (order_date, year, month)
SELECT DISTINCT
    Order_Date,
    EXTRACT(YEAR FROM Order_Date),
    EXTRACT(MONTH FROM Order_Date)
FROM sales_data;

--CREATE FACT TABLE--


CREATE TABLE fact_sales (
    sales_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    region_id INT,
    date_id INT,
    sales NUMERIC,
    profit NUMERIC,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (region_id) REFERENCES dim_region(region_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

--INSERT DATA INTO FACT TABLE--


INSERT INTO fact_sales (
    customer_id,
    product_id,
    region_id,
    date_id,
    sales,
    profit,
    quantity
)
SELECT
    c.customer_id,
    p.product_id,
    r.region_id,
    d.date_id,
    s.Sales,
    s.Profit,
    s.Quantity
FROM sales_data s
JOIN dim_customer c ON s.Customer_Name = c.customer_name
JOIN dim_product p ON s.Category = p.category
JOIN dim_region r ON s.Region = r.region
JOIN dim_date d ON s.Order_Date = d.order_date;


--CREATE INDEXES (Performance Optimization)--


CREATE INDEX idx_fact_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_product ON fact_sales(product_id);
CREATE INDEX idx_fact_region ON fact_sales(region_id);
CREATE INDEX idx_fact_date ON fact_sales(date_id);

--VALIDATION QUERIES--

SELECT COUNT(*) FROM sales_data;
SELECT COUNT(*) FROM fact_sales;

--Run analytics queries using star schema joins.--

SELECT
    r.region,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region;








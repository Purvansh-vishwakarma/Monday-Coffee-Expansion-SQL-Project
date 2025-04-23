create database coffee;
-- Monday Coffee SCHEMAS

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS city;

-- Import Rules
-- 1st import to city
-- 2nd import to products
-- 3rd import to customers
-- 4th import to sales


CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	FOREIGN KEY (product_id) REFERENCES products(product_id),
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

-- END of SCHEMAS

-- Data Analysis

select * from city;

-- 1) How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT city_name, 
ROUND( (population * 0.25)/1000000, 2) as coffee_consumers_in_millions,
city_rank
FROM city
ORDER BY 2 DESC;

-- 2) What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select city_name,
sum(total) as Total_revenue 
from sales s 
join customers c  
on s.customer_id = c.customer_id  
join city ci 
on ci.city_id =  c.city_id 
where 
      year(s.sale_date) = 2023
      and
      quarter(s.sale_date) = 4
group by city_name
order by sum(total) desc ;      
      

-- 3) How many units of each coffee product have been sold?

select
product_name,
count(sale_id) as Total_unit 
from products p left join sales s 
on p.product_id = s.product_id
group by product_name 
order by count(sale_id) desc;


-- 4) What is the average sales amount per customer in each city?

select city_name ,
round(sum(s.total)/count(distinct c.customer_id),2) as avg_sales
from sales s join customers c 
on s.customer_id = c.customer_id 
join city ci
on c.city_id = ci.city_id 
group by city_name
order by avg_sales desc;


-- 5) Provide a list of cities along with their populations and estimated coffee consumers.

select city_name,round((population/10000000),2) as Total_population,count( distinct c.customer_id) as coffee_consumers
from sales s join customers c 
on s.customer_id = c.customer_id 
join city ci 
on c.city_id = ci.city_id 
group by city_name,Total_population
order by Total_population desc;

-- 6) What are the top 3 selling products in each city based on sales volume?

select * from (
              select product_name,city_name, sum(Total) as sales_volume,
              dense_rank() over(partition by product_name order by Sum(total) desc) as rnk  
              from sales s 
              join customers c 
              on s.customer_id = c.customer_id
              join products p 
              on p.product_id = s.product_id
              join city ci on c.city_id = ci.city_id
              group by product_name,city_name)as x
              where x.rnk <4;
			
-- 7) How many unique customers are there in each city who have purchased coffee products?

SELECT 
ci.city_name,
COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY city_name;


-- 8) Find each city and their average sale per customer and avg rent per customer
SELECT 
    ci.city_name,
    COUNT(DISTINCT s.customer_id) AS total_cx,
    ROUND(SUM(s.total)/ COUNT(DISTINCT s.customer_id), 2) AS avg_sale_pr_cx,
    ROUND(ci.estimated_rent / COUNT(DISTINCT s.customer_id), 2) AS avg_rent_per_cx
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name, ci.estimated_rent
ORDER BY avg_sale_pr_cx DESC;


-- 9) Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    ci.estimated_rent,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    ROUND((ci.population * 0.25) / 1000000, 3) AS estimated_consumers_millions,
    ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sale_per_customer,
    ROUND(ci.estimated_rent / COUNT(DISTINCT s.customer_id), 2) AS avg_rent_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name, ci.estimated_rent, ci.population
ORDER BY total_revenue DESC;


/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.













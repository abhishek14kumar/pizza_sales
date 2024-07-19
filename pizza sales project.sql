create database pizza_shop;

use pizza_shop;

create table pizzas(
pizza_id VARCHAR(50) not null,
pizza_type_id varchar(50) not null,
size char(5) not null,
price FLOAT not null,
PRIMARY KEY(pizza_id));

create table pizza_types(
pizza_type_id VARCHAR(50) not null,
pizza_name varchar(75) not null,
category varchar(20) not null,
ingredients text not null,
PRIMARY KEY(pizza_type_id));

create table orders(
order_id int not null,
order_date DATE not null,
order_time TIME not null,
PRIMARY KEY(order_id));

create table order_details(
order_details_id INT not null,
order_id INT not null,
pizza_id VARCHAR(50) not null,
quantity INT not null,
PRIMARY KEY(order_details_id));

-- ---------------------------------------------------------------------------------------------------

-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- ---------------------------------------------------------------------------------------------------

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),2)
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- ---------------------------------------------------------------------------------------------------

-- Identify the highest-priced pizza.

SELECT 
    pizza_types.pizza_name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- ---------------------------------------------------------------------------------------------------

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- ---------------------------------------------------------------------------------------------------

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.pizza_name,
    SUM(order_details.quantity) AS total_quantity
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.pizza_name
ORDER BY total_quantity DESC
LIMIT 5;

-- ---------------------------------------------------------------------------------------------------

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- ---------------------------------------------------------------------------------------------------

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY Hour;

-- ---------------------------------------------------------------------------------------------------

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_name) AS pizza_count
FROM
    pizza_types
GROUP BY category;

-- ---------------------------------------------------------------------------------------------------

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_quantity), 0) AS avg_pizza_order
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS total_quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- ---------------------------------------------------------------------------------------------------

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.pizza_name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.pizza_name
ORDER BY revenue DESC
LIMIT 3;

-- ---------------------------------------------------------------------------------------------------

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- ---------------------------------------------------------------------------------------------------

-- Analyze the cumulative revenue generated over time.

select order_date, 
sum(revenue) over(order by order_date) as cumm_revenue
from
(select orders.order_date,
round(sum(order_details.quantity * pizzas.price),2) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- ---------------------------------------------------------------------------------------------------

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select * from
(select category, pizza_name, revenue,
rank() over(PARTITION BY category order by revenue desc) as rn from
(SELECT 
    pizza_types.category,
    pizza_types.pizza_name,
    SUM((order_details.quantity) * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.pizza_name) as a) as b
where rn <= 3;

-- ---------------------------------------------------------------------------------------------------











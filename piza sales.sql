-- Q1 Retrieve the total number of orders placed.
use pizzahut;
select count(order_id) as total_orders from orders;

-- Q2 Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
    
-- Q3 Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Q4 Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC; 

-- Q5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Q6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;

-- Q7 Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(ordr_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(ordr_time);

-- Q8 Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) from pizza_types
group by category

-- Q9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- Q10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Q11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
            SUM(od2.quantity * p2.price)
        FROM
            order_details od2
                JOIN
            pizzas p2 ON p2.pizza_id = od2.pizza_id) * 100,2) AS revenue_percentage
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;

-- Q12 Analyze the cumulative revenue generated over time.

SELECT order_date,
       SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT orders.order_date,
           SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS sales;

-- Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue 
FROM (
    SELECT category, name, revenue,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT pt.category, pt.name,
               SUM(od.quantity * p.price) AS revenue
        FROM pizza_types pt
        JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details od ON od.pizza_id = p.pizza_id
        GROUP BY pt.category, pt.name
    ) AS a
) AS b 
WHERE rn <= 3;








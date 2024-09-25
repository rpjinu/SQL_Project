use swiggy;

#to check all tables
select * from orders;
select * from users;
select * from restaurants;
select* from food;
select * from menu;
select * from order_details;

#1. Find customers who have never ordered
SELECT 
    name
FROM
    users
WHERE
    user_id NOT IN (SELECT 
            user_id
        FROM
            orders);

#2. Average Price/dish
SELECT 
    f.f_name, AVG(m.price) AS avg_price
FROM
    menu m
        JOIN
    food f ON m.f_id = f.f_id
GROUP BY f.f_name;


#3.Find the top restaurant in terms of the number of orders for a given month
SELECT  r.r_id,r.r_name, COUNT(*) AS months
FROM orders o 
JOIN restaurants r ON o.r_id = r.r_id 
WHERE MONTHNAME(o.date) LIKE 'June' 
GROUP BY  r.r_name,r.r_id
ORDER BY count(*) DESC 
LIMIT 100;


#4. restaurants with monthly sales greater than x for
select o.r_id,r.r_name,sum(o.amount) as revenue 
from orders o
JOIN restaurants r ON o.r_id = r.r_id 
where monthname(o.date) like 'June'
group by o.r_id,r.r_name
having  revenue >500                 #x=500
order by revenue desc;

#5. Show all orders with order details for a particular customer in a particular date range
SELECT 
    o.order_id,
    od.f_id,
    r.r_name AS restutant,
    f.f_name AS foodName
FROM
    orders o
        JOIN
    restaurants r ON o.r_id = r.r_id
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    food f ON f.f_id = od.f_id
WHERE
    user_id = (SELECT 
            user_id
        FROM
            users
        WHERE
            name LIKE 'ankit')
        AND (date > '2022-06-10'
        AND date < '2022-07-10');


#6. Find restaurants with max repeated customers
SELECT 
     r.r_name,COUNT(*) AS 'loyal_customer'
FROM
    (SELECT 
        r_id, user_id, COUNT(*) AS 'visits'
    FROM
        orders
    GROUP BY r_id , user_id
    HAVING visits > 1) t
join restaurants r on r.r_id=t.r_id
group by
    t.r_id,r.r_name
order by loyal_customer desc limit 1;




#7. Month over month revenue growth of swiggy
WITH sales AS (
    SELECT 
        monthname(date) AS 'months',
        SUM(amount) AS 'revenue'
    FROM 
        orders
    GROUP BY 
        monthname(date), month(date)
    ORDER BY 
        month(date)
    LIMIT 0, 1000
)
SELECT 
    months,revenue,
    (revenue - prev) / revenue * 100 AS growth_percentage
FROM (
    SELECT 
        months,
        revenue,
        LAG(revenue, 1) OVER (ORDER BY revenue) AS prev
    FROM 
        sales
) AS sales_with_prev;  -- Add an alias for the derived table



#8. Customer - favorite food
with temp as
(select o.user_id,u.name,od.f_id,f.f_name,count(*) as frequency from orders o
join order_details od on o.order_id=od.order_id
join food f on od.f_id=f.f_id
join users u on o.user_id=u.user_id
group by o.user_id,od.f_id,u.name,f_name
order by o.user_id
),
temp2 as(
select * from temp t1
where t1.frequency=(select max(frequency) from temp t2 where t1.user_id=t2.user_id)
)
select name,f_name from temp2;



#9.Find the most loyal customers for all restaurant
SELECT 
    r.r_name,
    COUNT(t.user_id) AS 'loyal_customer_count',
    GROUP_CONCAT(u.name) AS 'loyal_customers'
FROM
    (SELECT 
        r_id, user_id, COUNT(*) AS 'visits'
    FROM
        orders
    GROUP BY r_id, user_id
    HAVING visits > 1) t
JOIN 
    restaurants r ON r.r_id = t.r_id
JOIN 
    users u ON u.user_id = t.user_id
GROUP BY 
    t.r_id, r.r_name;


#10.Month over month revenue growth of a restaurant
WITH temp as
(SELECT 
        monthname(o.date) AS months,
        MONTH(o.date) AS month_num,
        SUM(o.amount) AS revenue
    FROM 
        orders o
    JOIN 
        restaurants r ON o.r_id = r.r_id
    WHERE 
        r.r_name LIKE 'kfc'
    GROUP BY 
        months,month_num
	ORDER BY 
        month_num
),
temp2 as(
select months,revenue,LAG(revenue,1) over(order by month_num) as prev_revenue
from temp
)
select months,revenue,
ROUND(((revenue - prev_revenue) / prev_revenue) * 100, 2) AS 'revenue_growth-%'
from temp2;


#11.Most Paired Products
WITH product_pairs AS (
    SELECT 
        LEAST(od1.f_id, od2.f_id) AS product_1,
        GREATEST(od1.f_id, od2.f_id) AS product_2,
        COUNT(*) AS pair_count
    FROM 
        order_details od1
    JOIN 
        order_details od2 
        ON od1.order_id = od2.order_id
        AND od1.f_id < od2.f_id
    GROUP BY 
        product_1, product_2
)
SELECT 
    product_1, 
    product_2, 
    pair_count
FROM 
    product_pairs
ORDER BY 
    pair_count DESC
LIMIT 10;


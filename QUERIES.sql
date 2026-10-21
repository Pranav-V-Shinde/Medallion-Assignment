/*
'''
### Part D — SQL practice
Use SQLite, PostgreSQL, SQL Server, or another SQL engine. Load the Silver transactions and dimensions into tables.

29. Write a query to return the 10 highest-value completed transactions.
30. Find total completed revenue by month.
31. Find revenue by product category.
32. Find the top 10 customers by completed revenue.
33. Find order count and revenue by city and state.
34. Calculate completed, cancelled, returned, and pending order counts.
35. Find customers who have never placed a completed order.
36. Find products with no transactions.
37. Use `ROW_NUMBER()` to find the latest transaction per customer.
38. Use `DENSE_RANK()` to rank product categories by revenue.
39. Use a CTE to calculate monthly revenue and month-over-month change.
40. Find duplicate `transaction_id` values using `GROUP BY` and `HAVING`.
41. Find customers whose completed revenue is above the average customer revenue.
42. Calculate each category's percentage contribution to total completed revenue.
43. Find the running total of daily completed revenue using a window function.
'''
*/

--29.
select * from dim_orders order by total_amt desc limit 10;

--30.
select month(cast(order_date as datetime)) as month,
       sum(total_amt) 
from dim_orders 
group by month(cast(order_date as datetime);

--31.
select category,sum(total_amt) from dim_orders group by category;

--32.
select customer_name,sum(total_amt) as lifetime_spend from dim_orders group by customer_name order by lifetime_spend desc limit 10;


--33.
select state,city,sum(total_amt) from dim_orders group by state,city;


--34.
select order_status,count(transaction_id) from dim_orders group by order_status;

--35.
with cte as (
    select distinct customer_id from dim_orders where order_status='completed'
)
select distinct customer_id from dim_orders where customer_id not in(select * from cte);

--36.
with cte as(
    select distinct product_id from dim_orders where transaction_id is not null 
)
select distinct product_id from dim_orders where product_id not in ( select * from cte);


--37.
with cte as(
    select * , row_number() over(partition by customer_id order by cast(order_date as datetime) desc ) rn from dim_orders
)
select * from cte where rn=1;

--38.
with cte as(
    select category,sum(total_amt) as total_cat_sale from dim_orders group by category
)
select * , dense_rank() over(order by total_cat_sale desc) as rn from cte;

--39.
with cte as(
        select MONTH(cast(order_date as datetime)) as month,  
                   YEAR(cast(order_date as datetime)) as year , 
                   sum(total_amt) as total_sale from dim_orders 
        group by MONTH(cast(order_date as datetime)),YEAR(cast(order_date as datetime))
        order by year asc , month asc
),
cte2 as(
        select *, lag(total_sale) over(order by year asc, month asc) as last_sale from cte
)
select *,total_sale-last_sale from cte2;


--40.
select transaction_id,count(*) from dim_orders group by transaction_id having count(*)>=1;

--41.
with cte as(
    select customer_id, sum(total_amt) as lifetime_spend from dim_orders group by customer_id
)
select distinct customer_id,lifetime_spend  
from cte 
where lifetime_spend> (
    select avg(total_amt) from dim_orders
);

--42
with cte as(
    select customer_id, sum(total_amt) as lifetime_spend from dim_orders group by customer_id
),
cte2 as(
        select sum(total_amt) as total_sale from dim_orders
)
select c1.*,(c1.lifetime_spend/c2.total_sale )*100 as emp_contrbution from cte c1, cte2 c2;


--43.
select *, 
    sum(total_amt) over(order by year(cast(order_date as datetime)) asc,
                        month(cast(order_date as datetime)) asc , 
                        date(cast(order_date as datetime)) asc  ) as running_sum  
from dim_orders;
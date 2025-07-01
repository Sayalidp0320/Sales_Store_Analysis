create table sales_store(
transaction_id varchar(15),
customer_id varchar(15),
customer_name varchar(30),
customer_age int,
gender varchar(15),
product_id varchar(15),
product_name varchar(15),
product_category varchar(15),
quantiy int,
prce float,
payment_mode varchar(15),
purchase_date date,
time_of_purchase time,
status varchar(15)
);

select * from sales_store;

------------------------------------------------importing data

copy sales_store(transaction_id,customer_id,customer_name,customer_age,gender,product_id,product_name,product_category,quantiy,prce,payment_mode,purchase_date,time_of_purchase,status)
from 'D:\sales_store.csv'
delimiter ','
csv header;

-------------------------------------------------Copy of data

select *  from sales_store;

select * into sales from sales_store

select * from sales


-------------------------------------------------data cleaning

--------step 1: To check for duplicate

select transaction_id, count(*)
from sales
group by transaction_id
having count(transaction_id)>1
---
with CTE as(
select *,
	row_number() over(partition by transaction_id order by transaction_id) as row_number
	from sales
) 
select * from CTE
where row_number>1
--where transaction_id in ('TXN240646','TXN342128','TXN855235','TXN981773')

----deleting duplicate records
delete from sales
where transaction_id in (
						select transaction_id 
						from (
							select *,
							row_number() over(partition by transaction_id order by transaction_id) as row_number
							from sales)
							where row_number>1
							); 
							
--------step 2: Correction of headers

alter table sales rename column quantiy to quantity
alter table sales rename column prce to price

--------step 3: To check null values

select * from sales
where transaction_id is null or
customer_id is null or
customer_name is null or
customer_age is null or
gender is null or
product_id is null or
product_name is null or
product_category is null or
quantity is null or
price is null or
payment_mode is null or
purchase_date is null or
time_of_purchase is null or
status is null;

---treating null values

delete from sales
where transaction_id is null

select * from sales
where customer_name='Ehsaan Ram'

update sales
set customer_id='CUST9494'
where transaction_id= 'TXN977900'

select * from sales
where customer_name='Damini Raju'

update sales
set customer_id='CUST1401'
where transaction_id= 'TXN985663'

select * from sales
where customer_id='CUST1003'

update sales
set customer_name= 'Mahika Saini' , customer_age= 35, gender= 'Male'
where transaction_id= 'TXN432798'

-------step 4: Checking formats

select distinct gender 
from sales

update sales
set gender='Male'
where gender='M'

update sales
set gender='Female'
where gender= 'F'

select distinct payment_mode
from sales

update sales
set payment_mode='Credit Card'
where payment_mode='CC'

select * from sales
-----------------------------------------------Data Analysis

--------Q1. What are top 5 selling products by quantity?

select product_name, sum(quantity) as total_quantity_sold
from sales
where status='delivered'
group by product_name
order by total_quantity_sold desc
limit 5;

--------Q2. Which products are most frequently cancelled?

select product_name, count(*) as total_cancelled
from sales
where status='cancelled'
group by product_name
order by total_cancelled desc
limit 5;

--------Q3: What time of the day has the highest number of purchase?

SELECT
    CASE 
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 18 AND 22 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS purchase_count
FROM sales
GROUP BY  time_of_day
ORDER BY purchase_count DESC;

--------Q4: Who are the top 5 highest spending customers?

select customer_name, sum(price*quantity) as total_spend
from sales
group by customer_name
order by total_spend desc
limit 5;


--------Q5: Which product categories generate the highest revenue?

select product_category, sum(price*quantity) as Revenue
from sales
group by product_category
order by Revenue desc


--------Q6: What is the return/cancellation rate per product category?

--cancellation
select product_category,
	TO_CHAR(
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*),
        'FM999.00%'
    ) AS cancelled_percentage
from sales
group by product_category
order by cancelled_percentage desc

--return
select product_category,
	TO_CHAR(
        COUNT(CASE WHEN status = 'returned' THEN 1 END) * 100.0 / COUNT(*),
        'FM999.00%'
    ) AS returned_percentage
from sales
group by product_category
order by returned_percentage desc

--------Q7: which is the most preferred payment mode?

select payment_mode, count(payment_mode) as total_count
from sales
group by payment_mode
order by total_count desc

--------Q8: How does age group affect purchasing behavior?

select
	case
		when customer_age between 18 and 25 then '18-25'
		when customer_age between 26 and 35 then '26-35'
		when customer_age between 36 and 50 then '36-50'
		else '51+'
	end as age_group,
	sum(price*quantity) as total_purchase
from sales
group by age_group
order by total_purchase desc;


--------Q9: What's the monthly sales trend?

select
	TO_CHAR(purchase_date, 'YYYY-MM') as year_month,
	sum(price*quantity) as total_sales,
	sum(quantity) as total_quantity
from sales
group by TO_CHAR(purchase_date, 'YYYY-MM')
ORDER BY year_month;


--------Q10: Are certain gender buying more specific product categories?

SELECT 
    product_category,
    COUNT(gender) FILTER (WHERE gender = 'Male') AS male,
    COUNT(gender) FILTER (WHERE gender = 'Female') AS female
FROM sales
GROUP BY product_category
ORDER BY product_category;




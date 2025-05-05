select * 
from coffee_sales;

-- 1. remove duplicate --
-- 2. standardize the data --
-- 3. null values or blank values --
-- 4. remove any columns --


 1. Remove duplicates
 -- is to get rid of repeated data --

-- [creating a second table to work with] -- 
-- create table coffe_sales_staging
-- like coffee_sales;

-- [selecting values from coffe_sales_staging] --
 select * 
 from coffe_sales_staging;

-- [inserting values to coffe_sales_staging] --
insert coffe_sales_staging
select *
from coffee_sales;

-- [1050 rows were partitioned] --
select *,
row_number() over(
partition by order_id, store_location, coffee_type, order_date, quantity, unit_price, customer_name, payment_method, total_price) as row_num
from coffe_sales_staging;

-- [50 rows with duplicates were returned] --
with duplicate_cte as (
select *,
row_number() over(
partition by order_id, store_location, coffee_type, order_date, quantity, unit_price, customer_name, payment_method, total_price) as row_num
from coffe_sales_staging)
select * 
from duplicate_cte
where row_num > 1;

-- [return duplicates valeus to double check] --
select *
from coffe_sales_staging
where store_location = 'Downtown'and order_date = '2023-09-26 00:00:00';

-- Returning all the values from coffe_sales_staging --
select *
from coffe_sales_staging;

-- [get rid of the duplicates] --
-- [create another table that has extra row and delete it where that row is more than 1 from the table]--
-- [creating a temprorary table so we can delete the duplicates] --

create table coffe_sales_staging2 (
order_id int,
store_location text, 
coffee_type text,
order_date text,
quantity int, 
unit_price double,
customer_name text, 
payment_method text, 
total_price double,
row_num int);

-- [Returning all the values from coffe_sales_staging2 and filter them] --
select *
from coffe_sales_staging2
where row_num > 1;

-- [inserting values into a temprorary table so we can delete the duplicates] --
insert into coffe_sales_staging2 
select *,
row_number() over(
partition by order_id, store_location, coffee_type, order_date, quantity, unit_price, customer_name, payment_method, total_price) as row_num
from coffe_sales_staging;

-- [now delete the duplicates] --
-- [SET SQL_SAFE_UPDATES = 0;] --
-- [50 duplicates rows are removed] --

 delete
from coffe_sales_staging2
where row_num > 1; --


2. Standardize the data
-- is to find issues in your data and fix them. --
-- [let remove spaces first]--
select store_location, trim(store_location)
from coffe_sales_staging2;

update coffe_sales_staging2
set store_location = trim(store_location);

-- [Return all the valuesfrom coffe_sales_staging]
select * from coffe_sales_staging;

-- [Fixing the typing errors on store_location]
 select distinct store_location from coffe_sales_staging;
 
 select store_location from coffe_sales_staging
where store_location like '%burb%';

 update coffe_sales_staging
set store_location = 'Uptown'
where store_location like 'Uptown%';

 # store_location
-- 'Suburb' - 16 rows changed
-- 'Airport' - 25 rows changed
-- 'Midtown' - 22 rows changed
-- 'Uptown' - 22 rows changed
-- 'Downtown' - 19 rows changed

-- [Fixing the typing errors on store_location]
select distinct coffee_type from coffe_sales_staging;
select coffee_type 
from coffe_sales_staging 
where coffee_type like '%ricano%';

-- Americano - 23 rows changed --
-- Mocha - 24 rows changed --
-- Latte - 20 rows changed  --
-- Espresso - 18 rows changed -- 
-- Cappuccino - 18 rows changed -- 

update coffe_sales_staging
set coffee_type = 'Cappuccino'
where coffee_type like '%puccino%';


select * from coffe_sales_staging;

-- Fixing the order_date from coffe_sales_staging --
SELECT DATE(order_date) AS order_date_clean
FROM coffe_sales_staging;

SELECT *
FROM coffe_sales_staging
WHERE STR_TO_DATE(order_date, '%Y-%m-%d') IS NULL;

SELECT 
  order_date,
  DATE_ADD(
    STR_TO_DATE(CONCAT(YEAR(order_date), '-', MONTH(order_date), '-01'), '%Y-%m-%d'),
    INTERVAL (DAY(order_date) - 1) DAY
  ) AS corrected_date
FROM coffe_sales_staging;


select * from coffe_sales_staging;

-- Fix the SQL using string functions --
SELECT 
  order_date,
  DATE_ADD(
    STR_TO_DATE(CONCAT(
      LEFT(order_date, 7), '-01'
    ), '%Y-%m-%d'),
    INTERVAL (SUBSTRING(order_date, 9, 2) - 1) DAY
  ) AS corrected_date
FROM coffe_sales_staging;


-- Change the oder_date to date format-- 
UPDATE coffe_sales_staging
SET order_date = DATE_ADD(
    STR_TO_DATE(CONCAT(
      LEFT(order_date, 7), '-01'
    ), '%Y-%m-%d'),
    INTERVAL (SUBSTRING(order_date, 9, 2) - 1) DAY
);

select * from coffe_sales_staging;


3. null values or blank values

-- [Replacing the blank values with unknown] --
select distinct quantity 
from coffe_sales_staging; -- No null values

select distinct unit_price 
from coffe_sales_staging order by 1; -- no null values

select distinct customer_name 
from coffe_sales_staging; -- 

UPDATE coffe_sales_staging
SET customer_name = 'Unknown'
WHERE customer_name IS NULL OR TRIM(customer_name) = '';

UPDATE coffe_sales_staging
SET payment_method = 'Unknown'
WHERE payment_method IS NULL OR TRIM(payment_method) = '';


-- [update total_price into 2 decimal] --
SELECT 
  total_price AS original_price,
  ROUND(total_price, 2) AS rounded_price
FROM coffe_sales_staging;

UPDATE coffe_sales_staging
SET total_price = ROUND(total_price, 2);


4. remove any columns
-- [successfully removed the row_num column] --
delete
from coffe_sales_staging2
where row_num > 1;


select * from coffe_sales_staging;




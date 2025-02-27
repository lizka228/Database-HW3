-- Вывести распределение (количество) клиентов по сферам деятельности, отсортировав результат по убыванию количества.

select job_industry_category
	, count(*) as count
from customer c 
group by c.job_industry_category 
order by count desc;
		
-- Найти сумму транзакций за каждый месяц по сферам деятельности, отсортировав по месяцам и по сфере деятельности. 

select c.job_industry_category
	, date_trunc('month', t.transaction_date::date) as month
	, sum(t.list_price) as sum
from customer c
join transactions t 
on c.customer_id = t.customer_id 
group by c.job_industry_category, month
order by c.job_industry_category, month;

-- Вывести количество онлайн-заказов для всех брендов в рамках подтвержденных заказов клиентов из сферы IT. 

select t.brand
	, count(*) as count
from "transaction" t 
join customer c 
on c.customer_id = t.customer_id 
where t.online_order = 'True' and t.order_status = 'Approved' and c.job_industry_category = 'IT'
group by t.brand
order by count desc;

-- Найти по всем  клиентам сумму всех транзакций (list_price), максимум, минимум и количество транзакций, отсортировав результат по убыванию суммы транзакций и количества клиентов. Выполните двумя способами: используя только group by и используя только оконные функции. Сравните результат. 

select customer_id
	, sum(list_price) as sum
	, max(list_price) as max
	, min(list_price) as min
	, count(list_price) as count
from "transaction" t 
group by customer_id 
order by sum desc, count desc;


select customer_id
	, list_price 
	, sum(list_price) over(partition by customer_id) as total_tran
	, max(list_price) over(partition by customer_id) as maximum 
	, min(list_price) over(partition by customer_id) as minimum
	, count(list_price) over(partition by customer_id) as count_tran
from "transaction" t 
order by total_tran desc, count_tran desc;

-- Найти имена и фамилии клиентов с минимальной/максимальной суммой транзакций за весь период (сумма транзакций не может быть null). Напишите отдельные запросы для минимальной и максимальной суммы. 

select sum(list_price) over(partition by customer_id) as summa1 -- смотрела минимальную суммарную трату
						from "transaction" t 
						order by summa1
						
select sum(list_price) over(partition by customer_id) as summa2 -- смотрела максимальную суммарная трату
						from "transaction" t 
						order by summa2 desc
						limit 1
     
select c.first_name 
	, c.last_name 
	, total -- максимальная суммарная трата
from (select t.customer_id,
         sum(t.list_price) as total
     from 
         transaction t
     where t.list_price is not null
     group by t.customer_id) trt
join customer c on c.customer_id = trt.customer_id
order by total desc
limit 1;


select c.first_name 
	, c.last_name 
	, total -- минимальная суммарная трата
from (select t.customer_id,
         sum(t.list_price) as total
     from 
         transaction t
     where t.list_price is not null
     group by t.customer_id) trt
join customer c on c.customer_id = trt.customer_id
order by total 
limit 1;


-- Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций. 

select *
from (select * 
		, row_number() over (partition by customer_id order by transaction_date::date) as first_date
	from transaction) as trt
where trt.first_date = 1;
		
-- Вывести имена, фамилии и профессии клиентов, между транзакциями которых был максимальный интервал (интервал вычисляется в днях).

select '2025-01-03'::date - '2025-01-01'::date as interval_days

select c.first_name
	, c.last_name
	, c.job_title
	, coalesce(trt.next_date::date - trt.transaction_date::date, 0) as interval_days
from(select t.customer_id
	, t.transaction_date::date
	, lead(transaction_date::date) over (partition by customer_id order by transaction_date::date) as next_date
	from transaction t) as trt
join customer c on c.customer_id = trt.customer_id
order by interval_days desc
limit 1;


-- 1. вывести количество фильмов в каждой категории, отсортировать по убыванию.
select 
fc.category_id ,
c.name ,
count(fc.film_id) as qty
from film_category as fc
left join category as c on c.category_id = fc.category_id 
group by fc.category_id, c.name
order by count(fc.film_id) desc


-- 2. вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
select 
a.actor_id ,
a.first_name ,
a.last_name ,
--fa.film_id ,
--i.inventory_id ,
--r.rental_id ,
count(r.rental_id) as rental_qty
from actor as a
left join film_actor as fa on fa.actor_id = a.actor_id 
left join inventory as i on i.film_id = fa.film_id 
left join rental as r on r.inventory_id = i.inventory_id 
group by a.actor_id , a.first_name , a.last_name 
order by count(r.rental_id) desc 
limit 10


-- 3. вывести категорию фильмов, на которую потратили больше всего денег.	
select 
c.category_id ,
c."name" ,
--fc.film_id ,
--i.inventory_id ,
--r.rental_id ,
--p.amount ,
sum(p.amount) as summ
from category as c 
left join film_category as fc on fc.category_id = c.category_id 
left join inventory as i on i.film_id = fc.film_id 
left join rental as r on r.inventory_id = i.inventory_id 
left join payment as p on p.rental_id = r.rental_id 
group by c.category_id , c."name" 
order by sum(p.amount) desc 
limit 1

-- 4. вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.
select 
f.title 
from film as f
left join inventory as i on i.film_id = f.film_id 
where i.film_id is null
group by f.title 


-- 5. вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.
select 
t1.actor_id,
t1.first_name,
t1.last_name
from 
	(
	select 
	a.actor_id ,
	a.first_name ,
	a.last_name ,
	count(fa.film_id) as film_qty ,
	dense_rank() over(order by count(fa.film_id) desc) as ranking
	from actor a 
	left join film_actor fa on fa.actor_id = a.actor_id 
	left join film_category fc on fc.film_id = fa.film_id 
	left join category c on c.category_id  = fc.category_id 
	where c."name" = 'Children'
	group by a.actor_id , a.first_name , a.last_name
	order by count(fa.film_id) desc 
	) as t1
where t1.ranking <= 3


-- 6. вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.
select 
c.city_id ,
c.city ,
--a.address_id ,
--c2.customer_id ,
count(j1.customer_id) as active_qty,
count(j2.customer_id) as inactive_qty
from city as c 
left join address as a on a.city_id = c.city_id 
left join customer as c2 on c2.address_id = a.address_id 
left join 
	(
	select c3.customer_id from customer as c3 where c3.active = 1
	) as j1 on j1.customer_id = c2.customer_id 
left join 
	(
	select c3.customer_id from customer as c3 where c3.active = 0
	) as j2 on j2.customer_id = c2.customer_id 
group by c.city_id , c.city 
order by count(j2.customer_id) desc 


-- 7. вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), 
-- и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
select 
c.category_id ,
c."name" ,
--fc.film_id ,
--i.inventory_id ,
--r.customer_id ,
--c2.address_id ,
--a.city_id ,
--c3.city ,
count(c2.address_id) as film_qty
from category as c 
left join film_category as fc on fc.category_id = c.category_id 
left join inventory as i on i.film_id = fc.film_id 
left join rental as r on r.inventory_id = i.inventory_id 
left join customer as c2 on c2.customer_id = r.customer_id 
left join address as a on a.address_id = c2.address_id 
left join city as c3 on c3.city_id = a.city_id 
where c3.city like 'a%' or c3.city like '%-%'
group by c.category_id , c."name" 
order by count(c2.address_id) desc 
limit 1

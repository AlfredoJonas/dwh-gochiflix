-- HECHO # 2, CANTIDAD, GANANCIAS Y TIEMPO DE ALQUILER PROMEDIO DE PELICULAS POR CATEGORIA PARA CADA CLIENTE EN CADA TIENDA

select 
	extract(year from rent.rental_date) as yyyy,
	extract(month from rent.rental_date) as mm,
	cust.customer_id,
	cate.category_id,
	sto.store_id,
	count(*) as quantity, 
	--(count(*) * )
	sum(pay.amount) as revenue,
	avg(rent.return_date - rent.rental_date) as avg_time
from rental rent
join customer cust on rent.customer_id = cust.customer_id
join inventory inv on rent.inventory_id = inv.inventory_id
join film f on f.film_id = inv.inventory_id
join film_category fc on f.film_id = fc.film_id
join category cate on fc.category_id = cate.category_id
join staff st on rent.staff_id = st.staff_id
join "store" sto on st.store_id = sto.store_id
join payment pay on rent.rental_id = pay.rental_id
--group by rent.rental_id
group by yyyy, mm, cust.customer_id, cate.category_id, sto.store_id

-- HECHO # 3: CANTIDAD, GANANCIAS Y TIEMPO DE ALQUILER PROMEDIO DE PELICULAS POR ACTOR PARA CADA CLIENTE EN CADA TIENDA

select 
	extract(year from rent.rental_date) as yyyy,
	extract(month from rent.rental_date) as mm,
	cust.customer_id,
	act.actor_id,
	sto.store_id,
	count(*) as quantity, 
	--(count(*) * )
	sum(pay.amount) as revenue,
	avg(rent.return_date - rent.rental_date) as avg_time
from rental rent
join customer cust on rent.customer_id = cust.customer_id
join inventory inv on rent.inventory_id = inv.inventory_id
join film f on f.film_id = inv.inventory_id
join film_actor fa on f.film_id = fa.actor_id
join actor act on fa.actor_id = act.actor_id
join staff st on rent.staff_id = st.staff_id
join "store" sto on st.store_id = sto.store_id
join payment pay on rent.rental_id = pay.rental_id
--group by rent.rental_id
group by yyyy, mm, cust.customer_id, act.actor_id, sto.store_id
-- HECHO #1: CANTIDA, GANANCIAS Y ESPERAS GENERADAS POR UNA PELICULA ALQUILADA EN UNA TIENDA ESPECIFICA EN UN DIA DADO POR UN EMPLEADO EN ESPECIFICO

select 
	rent.rental_date::date as "date",
	sto.store_id,
	st.staff_id,
	f.film_id,
	count(*) as quantity,
	sum(pay.amount) as revenue,
	avg(coalesce(rent.return_date,now()) - rent.rental_date) as avg_time,
	-- calculate_wait_quantity( rent.rental_date::date as "date", sto.store_id, st.staff_id, f.film_id ) as wait_quantity
	calculate_wait_quantity( rent.rental_date::date, sto.store_id, f.film_id ) as wait_quantity
from rental rent
join customer cust on rent.customer_id = cust.customer_id
join inventory inv on rent.inventory_id = inv.inventory_id
join film f on f.film_id = inv.inventory_id
join staff st on rent.staff_id = st.staff_id
join "store" sto on st.store_id = sto.store_id
join payment pay on rent.rental_id = pay.rental_id
--group by rent.rental_id
group by rent.rental_date, f.film_id, st.staff_id, sto.store_id 
order by "date", store_id, staff_id, film_id

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
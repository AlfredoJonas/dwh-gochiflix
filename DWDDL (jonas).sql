-- DIMENSION TIEMPO

CREATE SEQUENCE time_id_seq;
CREATE TABLE dim_time
    ( time_id            INTEGER default nextval('time_id_seq') PRIMARY KEY
	, original_id INTEGER
    , date           timestamp without time zone NOT NULL
    , day_           integer NOT NULL
    , month_         integer NOT NULL
    , year_          integer NOT NULL
    );
ALTER SEQUENCE time_id_seq owned by dim_time.time_id;

--DIMENSION PELICULA

CREATE SEQUENCE film_id_seq;
CREATE TABLE dim_film
    ( film_id INTEGER default nextval('film_id_seq') PRIMARY KEY
	, original_id INTEGER
    , title              VARCHAR(40)
    , languaje VARCHAR(20)
    , rental_duration NUMERIC(2)
    , rating VARCHAR(10)
    );
ALTER SEQUENCE film_id_seq owned by dim_film.film_id;

-- DIMENSION EMPLEADO

CREATE SEQUENCE staff_id_seq;
CREATE TABLE dim_staff
    ( staff_id INTEGER default nextval('staff_id_seq') PRIMARY KEY
    	, original_id		INTEGER
	, first_name              VARCHAR(40)
    , last_name          VARCHAR(10)
    );
ALTER SEQUENCE staff_id_seq owned by dim_staff.staff_id;


-- DIMENSION TIENDAS 

CREATE SEQUENCE store_id_seq;
CREATE TABLE dim_store
    ( store_id INTEGER default nextval('store_id_seq') PRIMARY KEY
	, original_id INTEGER
    , address        VARCHAR(100)
    , address2         VARCHAR(100)
	, district        VARCHAR(100)
    , city         VARCHAR(50)
	, postal_code        VARCHAR(20)
    );
ALTER SEQUENCE store_id_seq owned by dim_store.store_id;

-- DIMENSION CATEGORIA

CREATE SEQUENCE category_id_seq;
CREATE TABLE dim_category
    ( category_id INTEGER default nextval('category_id_seq') PRIMARY KEY
	, original_id INTEGER
    , name              VARCHAR(40)
    );
ALTER SEQUENCE category_id_seq owned by dim_category.category_id;

-- DIMENSION CLIENTE

CREATE SEQUENCE client_id_seq;
CREATE TABLE dim_client
    ( client_id INTEGER default nextval('client_id_seq') PRIMARY KEY
    	, original_id		INTEGER
	, first_name              VARCHAR(40)
    , last_name          VARCHAR(40)
    );
ALTER SEQUENCE client_id_seq owned by dim_client.client_id;

-- DIMENSION ACTOR


CREATE SEQUENCE actor_id_seq;
CREATE TABLE dim_actor
    ( actor_id INTEGER default nextval('actor_id_seq') PRIMARY KEY
	, original_id INTEGER
    , first_name VARCHAR(40),
      last_name VARCHAR(40)
    );
ALTER SEQUENCE actor_id_seq owned by dim_actor.actor_id;




-- HECHO: BENEFICIO ALQUILERES POR PELICULA

CREATE TABLE fact_per_film_rental
    ( time_id         INTEGER REFERENCES dim_time(time_id)
    , film_id          INTEGER REFERENCES dim_film(film_id)
    , staff_id       INTEGER REFERENCES dim_staff(staff_id)
    , store_id         INTEGER REFERENCES dim_store(store_id)
    , wait_quantity          NUMERIC(5)
	, quantity          NUMERIC(10)
    , revenue       NUMERIC(10,2)
	, avg_time CHARACTER VARYING
	, primary key (time_id, film_id, staff_id, store_id)
    );

-- HECHO: TABLA AUXILIAR

CREATE TABLE fact_per_film_rental_aux
    ( time_id         INTEGER REFERENCES dim_time(time_id)
    , film_id          INTEGER REFERENCES dim_film(film_id)
    , staff_id       INTEGER REFERENCES dim_staff(staff_id)
    , store_id         INTEGER REFERENCES dim_store(store_id)
    , rental_date          timestamp without time zone NOT NULL
    , return_date          timestamp without time zone
    , amount       numeric(5,2) NOT NULL
    );

-- HECHO: BENEFICIO POR CLIENTE Y POR CATEGORIAS

CREATE TABLE fact_client_category_rental
    ( time_id         INTEGER REFERENCES dim_time(time_id)
    , client_id          INTEGER REFERENCES dim_client(client_id)
    , category_id       INTEGER REFERENCES dim_category(category_id)
    , store_id         INTEGER REFERENCES dim_store(store_id)
	, quantity          NUMERIC(10)
    , revenue       NUMERIC(10,2)
	, avg_time CHARACTER VARYING
	, primary key (time_id, client_id, category_id, store_id)
    );

-- HECHO: TABLA AUXILIAR

CREATE TABLE fact_client_category_rental_aux
    ( time_id         INTEGER REFERENCES dim_time(time_id)
    , client_id          INTEGER REFERENCES dim_client(client_id)
    , category_id       INTEGER REFERENCES dim_category(category_id)
    , store_id         INTEGER REFERENCES dim_store(store_id)
	, rental_date          timestamp without time zone NOT NULL
    , return_date          timestamp without time zone
    , amount       numeric(5,2) NOT NULL
    );

-- HECHO: BENEFICIO POR CLIENTE Y POR ACTOR

CREATE TABLE fact_client_actor_rental
    ( time_id         INTEGER REFERENCES dim_time(time_id)
    , client_id          INTEGER REFERENCES dim_client(client_id)
    , actor_id       INTEGER REFERENCES dim_actor(actor_id)
    , store_id         INTEGER REFERENCES dim_store(store_id)
	, quantity          NUMERIC(10)
    , revenue       NUMERIC(10,2)
	, avg_time CHARACTER VARYING
	, primary key (time_id, client_id, actor_id, store_id)
    );

-- HECHO: TABLA AUXILIAR

CREATE TABLE fact_client_actor_rental_aux
    ( time_id         INTEGER REFERENCES dim_time(time_id)
    , client_id          INTEGER REFERENCES dim_client(client_id)
    , actor_id       INTEGER REFERENCES dim_actor(actor_id)
    , store_id         INTEGER REFERENCES dim_store(store_id)
	, rental_date          timestamp without time zone NOT NULL
    , return_date          timestamp without time zone
    , amount       numeric(5,2) NOT NULL
    );




CREATE OR REPLACE FUNCTION public.calculate_wait_quantity
(fecha date, tienda_id int, pelicula_id	int)
    RETURNS int
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

DECLARE
    
    curs CURSOR FOR
    select title, rental_date as "date", 0 as "type" from inventory join film using(film_id) join rental using(inventory_id) where store_id = tienda_id and rental_date = fecha and film_id = pelicula_id
 	UNION
 	select title, return_date as "date", 1 as "type" from inventory join film using(film_id) join rental using(inventory_id) where store_id = tienda_id and return_date = fecha and film_id = pelicula_id order by title, date;
	
    fila record;
    titulo film.title%type;
    contador int;
    esperas int:=0;
    total int;
    last_date date;

BEGIN
	select into total count(*) from film join inventory using(film_id) where film_id = pelicula_id;

	FOR	fila in curs loop
    		
            if fila.type = 0 then
--            	raise notice 'rentar';
            	if contador > 0 then
--                	raise notice 'rentado';
            		contador := contador - 1;
--                    raise notice 'last_date: % date: %',last_date,fila.date;
                    if extract(year from fila.date - last_date) = 0 and extract(month from fila.date - last_date) = 0 and extract(day from fila.date - last_date) = 0 and (extract(hour from fila.date - last_date) < 3 or extract(hour from fila.date - last_date) = 3 and extract(minute from fila.date - last_date) = 0 and extract(second from fila.date - last_date) = 0) then
                    	raise notice 'espera++';
                        esperas := esperas + 1;
                    end if;
                end if;	
            elsif fila.date is not null then
--            	raise notice 'devolver';
            	if contador < total then
--                	raise notice 'devuelto';
                	contador := contador + 1;
                	if contador = 1 then
--                    	raise notice 'last_date';
                    	last_date := fila.date;
                    end if;
                end if;
            end if;            
    end loop;
    
    return esperas;
END 
$function$;

ALTER FUNCTION public.esperas()
    OWNER TO postgres;
       
 select calculate_wait_quantity(to_date('2005-05-24', 'DD MM YYYY'), 1, 333);
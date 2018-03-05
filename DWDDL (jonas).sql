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
	, avg_time NUMERIC(5,2)
	, primary key (time_id, film_id, staff_id, store_id)
    );

-- HECHO: BENEFICIO POR CLIENTE Y POR CATEGORIAS

CREATE TABLE fact_client_category_rental
    ( time_id         INTEGER REFERENCES dim_time(time_id)
    , client_id          INTEGER REFERENCES dim_client(client_id)
    , category_id       INTEGER REFERENCES dim_category(category_id)
    , store_id         INTEGER REFERENCES dim_store(store_id)
	, quantity          NUMERIC(10)
    , revenue       NUMERIC(10,2)
	, avg_time NUMERIC(5,2)
	, primary key (time_id, client_id, category_id, store_id)
    );

-- HECHO: BENEFICIO POR CLIENTE Y POR ACTOR

CREATE TABLE fact_client_actor_rental
    ( time_id         INTEGER REFERENCES dim_time(time_id)
    , client_id          INTEGER REFERENCES dim_client(client_id)
    , actor_id       INTEGER REFERENCES dim_actor(actor_id)
    , store_id         INTEGER REFERENCES dim_store(store_id)
	, quantity          NUMERIC(10)
    , revenue       NUMERIC(10,2)
	, avg_time NUMERIC(5,2)
	, primary key (time_id, client_id, actor_id, store_id)
    );


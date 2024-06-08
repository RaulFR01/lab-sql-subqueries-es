use sakila;

-- ¿Cuántas copias de la película _El Jorobado Imposible_ existen en el sistema de inventario?
SELECT f.title, sub.STOCK
FROM film f
JOIN(
SELECT i.film_id,  count(*) AS STOCK
FROM inventory i
GROUP BY i.film_id
) sub
ON f.film_id = sub.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE';

-- Lista todas las películas cuya duración sea mayor que el promedio de todas las películas.

SELECT f.film_id, f.title
FROM FILM f
WHERE f.length > (
SELECT AVG(f.length) as AVERAGE
FROM FILM f
);

-- Usa subconsultas para mostrar todos los actores que aparecen en la película _Viaje Solo_

SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN (
SELECT f.film_id
FROM FILM f
WHERE f.title = 'ALONE TRIP'
) sub
ON fa.film_id = sub.film_id;

-- Las ventas han estado disminuyendo entre las familias jóvenes, y deseas dirigir todas las películas familiares a una promoción. 
-- Identifica todas las películas categorizadas como películas familiares.

SELECT f.film_id, f.title
FROM film_category fc
JOIN (
SELECT c.category_id
FROM category c
WHERE c.name = 'Family'
) sub
ON fc.category_id = sub.category_id
JOIN film f
ON fc.film_id = f.film_id;

-- Obtén el nombre y correo electrónico de los clientes de Canadá usando subconsultas. Haz lo mismo con uniones. 
-- Ten en cuenta que para crear una unión, tendrás que identificar las tablas correctas con sus claves primarias y claves foráneas, que te ayudarán a obtener la información relevante

SELECT c.first_name, c.email
FROM customer c
JOIN address a
ON c.address_id = a.address_id
JOIN
(SELECT c.city_id
FROM country co
JOIN city c
ON co.country_id = c.country_id
WHERE co.country = 'Canada') sub
ON a.city_id = sub.city_id;

SELECT cu.first_name, cu.email
FROM customer cu
JOIN address a
ON cu.address_id = a.address_id
JOIN city c
ON a.city_id = c.city_id
JOIN country co
ON co.country_id = c.country_id
WHERE co.country = 'Canada';

-- ¿Cuáles son las películas protagonizadas por el actor más prolífico? El actor más prolífico se define como el actor que ha actuado en el mayor número de películas. 
-- Primero tendrás que encontrar al actor más prolífico y luego usar ese actor_id para encontrar las diferentes películas en las que ha protagonizado

SELECT f.title
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
JOIN(
SELECT a.actor_id, count(*) AS Numero_de_pelis
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY Numero_de_pelis DESC
LIMIT 1
) sub
ON fa.actor_id = sub.actor_id;

-- Películas alquiladas por el cliente más rentable. 
-- Puedes usar la tabla de clientes y la tabla de pagos para encontrar al cliente más rentable, es decir, el cliente que ha realizado la mayor suma de pagos

SELECT c.first_name, c.last_name
from customer c
JOIN(
SELECT c.customer_id, sum(p.amount) AS Rentabilidad
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY Rentabilidad DESC
LIMIT 1) sub
ON c.customer_id = sub.customer_id;

-- Obtén el `client_id` y el `total_amount_spent` de esos clientes que gastaron más que el promedio del `total_amount` gastado por cada cliente.

WITH cte_suma AS (
    SELECT p.customer_id, SUM(p.amount) AS suma_amount
    FROM payment p
    GROUP BY p.customer_id
)

SELECT customer_id 
FROM cte_suma
WHERE suma_amount > (SELECT AVG(suma_amount) from cte_suma)
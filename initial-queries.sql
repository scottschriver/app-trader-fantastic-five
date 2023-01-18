/*SELECT name, COUNT(name)
FROM play_store_apps
GROUP BY name;*/


/*To find duplicates in table
SELECT name, COUNT(*)
FROM app_store_apps
GROUP BY name
HAVING COUNT(*) > 1*/


-- app store apps top rating by genre
/*select DISTINCT primary_genre, COUNT(name)
from app_store_apps
WHERE rating > 4.5
GROUP BY DISTINCT primary_genre
ORDER BY COUNT(name) DESC*/

-- play store apps top rating by genre
/*Select DISTINCT genres, COUNT(name)
from play_store_apps
WHERE rating > 4.5
GROUP BY DISTINCT genres
ORDER BY COUNT(name) DESC*/

-- app store avg price of apps over $1.00 by genre
/*SELECT primary_genre, avg(price)
FROM app_store_apps
WHERE price > 1
group by primary_genre
order by avg(price) DESC*/

-- play store avg price of apps over $1.00 by genre
/*SELECT primary_genre, avg(price)
FROM play_store_apps
WHERE price > 1
group by category
order by avg(price) DESC*/

/*SELECT name, a.price AS app_price, p.price::money::decimal AS play_price, a.rating AS app_rating, p.rating AS play_rating, a.review_count AS app_reviews, p.review_count AS play_reviews, p.content_rating, p.genres
FROM App_store_apps AS a
	INNER JOIN play_store_apps AS p
	USING (name);*/
	
/*Scott-find data types for all columns in both tables
SELECT 'app-store' AS table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'app_store_apps'
UNION
SELECT 'play_store' AS table, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'play_store_apps'
ORDER BY table_name;*/

/*Phil-find lifespan and sort by lifespan descending
SELECT name, a.price AS app_price,
p.price::money::decimal AS play_price,
a.rating AS app_rating,
p.rating AS play_rating,
a.review_count AS app_reviews,
p.review_count AS play_reviews,
p.content_rating,
p.genres as play_genre,
a.primary_genre as app_genre,
round((a.rating+p.rating)/2*2+1,1) as lifespan_years,
trim(trailing '+' from p.install_count) as play_installs
FROM App_store_apps AS a
	INNER JOIN play_store_apps AS p
	USING (name)
	order by lifespan_years desc*/
	
--Iulia's Code
/*SELECT play_store_genre, row_number() OVER (PARTITION BY play_store_genre ORDER BY total_revenue DESC) AS genre_rank,
	name, total_revenue
FROM
--table join for free apps
	(SELECT DISTINCT a.name,
		a.price as app_price,
		p.price::money::decimal as play_price,
		a.rating as app_rating,
		p.rating as play_rating,
	 	a.primary_genre as app_store_genre,
		p.genres as play_store_genre,
		round((a.rating+p.rating)/2*2+1,1) as lifespan_years,
		(((round((a.rating+p.rating)/2*2+1,0))*12)*5000) as estimated_revenue,
		(((round((a.rating+p.rating)/2*2+1,0))*12)*1000)+10000 as estimated_spending,
		((((round((a.rating+p.rating)/2*2+1,0))*12)*5000))
		-(((round((a.rating+p.rating)/2*2+1,0))*12)*1000)+10000 as
		total_revenue
	FROM app_store_apps as a
	JOIN play_store_apps as p
	ON UPPER(a.name) = UPPER(p.name)
	--above formula changes if paid app equal to 10000*price
	WHERE a.price <= 1 AND p.price::money::decimal <= 1
	AND CAST(a.review_count as decimal) >=100
	AND CAST(p.review_count as decimal) >= 100
	AND a.rating >= 3.5 AND p.rating>= 3.5
	order by lifespan_years DESC) AS freeboth;*/


--Iulia's revised code
/*SELECT
app_store_name,
play_store_name,
app_rating,
game_rating,
app_price,
game_price,
lifespan_years,
lifespan_months,
(lifespan_months*5000) as estimated_revenue,
(lifespan_months*1000)+10000 as estimated_spending,
(lifespan_months*5000) - ((lifespan_months*1000)+10000) as
total_revenue
FROM(select
DISTINCT
a.name as app_store_name,
p.name as play_store_name,
a.price as app_price,
p.price::money::decimal as game_price,
a.rating as app_rating,
p.rating as game_rating,
a.primary_genre as app_store_genre,
p.genres as play_store_genre,
round((a.rating+p.rating)/2*2+1,1) as lifespan_years,	
round(((a.rating+p.rating)/2*2+1)*12,1) lifespan_months
from app_store_apps as a
JOIN play_store_apps as p
ON a.name = p.name
WHERE a.price < 1 AND p.price::money::decimal <1
AND CAST(a.review_count as decimal) >=100
AND CAST(p.review_count as decimal) >= 100
AND a.rating >= 3.5 AND p.rating>= 3.5
order by lifespan_months DESC) as subquery;*/


--order top 10 apps by each genre
SELECT
app_store_genre,
app_store_name,
row_number() OVER (PARTITION BY app_store_genre ORDER BY total_revenue) AS genre_rank
FROM(
	SELECT
	app_store_genre,
	play_store_genre,
	app_store_name,
	play_store_name,
	app_rating,
	game_rating,
	app_price,
	game_price,
	lifespan_years,
	lifespan_months,
	(lifespan_months*5000) as estimated_revenue,
	(lifespan_months*1000)+10000 as estimated_spending,
	(lifespan_months*5000) - ((lifespan_months*1000)+10000) as total_revenue
	FROM(
			--inner freeboth query
			SELECT
			DISTINCT
			a.name as app_store_name,
			p.name as play_store_name,
			a.price as app_price,
			p.price::money::decimal as game_price,
			a.rating as app_rating,
			p.rating as game_rating,
			a.primary_genre as app_store_genre,
			p.genres as play_store_genre,
			round((a.rating+p.rating)/2*2+1,1) as lifespan_years,	
			round(((a.rating+p.rating)/2*2+1)*12,1) lifespan_months
			FROM app_store_apps as a
			JOIN play_store_apps as p
			ON a.name = p.name
			WHERE a.price < 1 AND p.price::money::decimal < 1
			AND CAST(a.review_count as decimal) >=100
			AND CAST(p.review_count as decimal) >= 100
			AND a.rating >= 3.5 AND p.rating>= 3.5
			--freeboth is the inner main table query
			ORDER BY lifespan_months DESC) as freeboth) AS genre_rank

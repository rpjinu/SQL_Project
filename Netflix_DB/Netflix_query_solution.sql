select * from netflix;

---1. Count the number of Movies vs TV Shows
select type,count(*) as count_types from netflix
group by type;

--2. Find the most common rating for movies and TV shows
with rating_counts as
(
select type,rating,count(*) as rating_count from netflix
group by type,rating
),
rating_rank as(
select type,rating,rating_count,
RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
from rating_counts
)
select type,
    rating AS common_rating
FROM rating_rank
WHERE rank = 1;


---3. List all movies released in a specific year (e.g., 2020)
select * from netflix
where release_year=2020 and type='Movie';


---4. Find the top 5 countries with the most content on Netflix
select 
 UNNEST(STRING_TO_ARRAY(country, ',')) as individual_country,
 count(*) as total_content
 from netflix
 group by 1
 order by total_content desc limit 5;


---5. Identify the longest movie

select title as movie_title,cast(REGEXP_SUBSTR(duration, '[0-9]+')as integer) AS movie_duration_mins
from netflix
where type='Movie' AND duration IS NOT NULL
order by movie_duration_mins desc limit 10;


---6. Find content added in the last 5 years
select * from netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


---7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select director_name,* from(
select *,unnest(STRING_TO_ARRAY(director,',')) as director_name from netflix
)
where director_name='Rajiv Chilaka';

---8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show' 
  AND split_part(duration, ' ', 1)::int > 5;

---9. Count the number of content items in each genre
select unnest(STRING_TO_ARRAY(listed_in,',')) as genre,
count(*) as total_content
from netflix
group by genre;


---10.Find each year and the average numbers of content release in India on netflix.
---return top 5 year with highest avg content release!
SELECT 
	country,
	release_year,
	COUNT(*) as total_release,
	ROUND(
		COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country,2
ORDER BY avg_release DESC limit 5;


---11. List all movies that are documentaries
select * from(
select 
title,type,unnest(STRING_TO_ARRAY(listed_in,',')) as genre
from netflix
where type='Movie')
where genre='Documentaries'; 

---2 way 
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';

---12. Find all content without a director
SELECT * 
FROM netflix
WHERE director IS NULL;


---13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS cast_name,*
    FROM netflix
) AS cast_table
WHERE cast_name = 'Salman Khan'AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

	
---14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select cast_name,count(*)as total_movies 
from(
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS cast_name,*
    FROM netflix) as t
 where type='Movie' and country = 'India'
 group by cast_name
 order by total_movies desc limit 10;
	


---15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
SELECT 
    CASE 
        WHEN description LIKE '%kill%' OR description LIKE '%violence%' 
        THEN 'Bad' 
        ELSE 'Good' 
    END AS content_category,
    COUNT(*) AS content_count
FROM netflix
GROUP BY content_category;


---thank you
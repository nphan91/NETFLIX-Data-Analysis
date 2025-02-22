SELECT *
FROM [dbo].[netflix_titles];

-- 1. Count the Number of Movies vs TV Shows
SELECT 
    [type],
    COUNT(*)
FROM [dbo].[netflix_titles]
GROUP BY [type];
-- Objective: The aim of this analysis is to examine the distribution of content types (Movies vs TV Shows) in the Netflix catalog. 
-- By counting the number of occurrences of each content type, we can better understand the proportion of Movies and TV Shows available.
-- Results:
--Movies: There are 6,131 Movies in the Netflix catalog.
--TV Shows: There are 2,676 TV Shows in the Netflix catalog.
--Implications:

--The data shows that Movies make up the larger portion of the content available on Netflix, with Movies outnumbering TV Shows by a significant margin (approximately 2.3 times more Movies than TV Shows).
--This distribution could indicate a greater focus on standalone films compared to episodic TV content

--2. Find the Most Common Rating for Movies and TV Shows

WITH RankedRatings AS (
    SELECT 
        [type],
        [rating],
        RANK() OVER (PARTITION BY [type] ORDER BY COUNT (*) DESC) AS rank
    FROM [dbo].[netflix_titles]
    GROUP BY [type], [rating]
)
SELECT 
    [type],
    [rating] AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- Objective: The goal of this analysis is to identify which rating appears most frequently for each content type (e.g., Movies and TV Shows) in the netflix_titles dataset. 
-- Result: 
--The analysis revealed that the most frequently occurring rating for both Movies and TV Shows in the dataset is TV-MA.
--This finding suggests that content labeled as TV-MA (intended for mature audiences) is highly prevalent across both content types.

--3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT *
FROM [dbo].[netflix_titles]
WHERE [release_year] = '2020' AND [type] = 'Movie';

--Objective:
--The goal of this analysis is to retrieve all Movies that were released in the year 2020 on Netflix. 
--This will help us examine the volume and distribution of Movies released in a specific year, providing insights into Netflix's content catalog for that time period.
--Results:

--Total Movies Released in 2020: A total of 571 Movies were released on Netflix in the year 2020.

--4. Find the Top 5 Countries with the Most Content on Netflix
SELECT TOP 5 
    TRIM(value) AS country,
    COUNT(*) AS total_content
FROM 
    [dbo].[netflix_titles]
    CROSS APPLY STRING_SPLIT(country, ',') -- Split the country list by commas
WHERE 
    country IS NOT NULL
GROUP BY 
    TRIM(value)
ORDER BY 
    total_content DESC;
--	Objective:
--The goal is to identify the top 5 countries with the highest number of content items (movies, TV shows, etc.) available on Netflix. 
--This analysis provides insight into the distribution of Netflix's content across various regions, 
--helping to understand which countries dominate the platform in terms of content availability.

--Result:
--The following table presents the top 5 countries with the most content available on Netflix:
--United States		3,690
--India				1,046
--United Kingdom	806
--Canada			445
--France			393


--5. Identify the Longest Movie
SELECT *
FROM [dbo].[netflix_titles]
WHERE  [type] = 'Movie'
AND ISNUMERIC(REPLACE([duration], ' min', '')) = 1  -- Ensure only valid durations are considered
ORDER BY CAST(REPLACE([duration], ' min', '') AS INT) DESC;

--Objective:
--The purpose of this query is to determine the movie with the longest duration on Netflix. 
--By analyzing the dataset, we aim to identify which title has the highest runtime, ensuring that only valid numeric durations are considered.
--The analysis reveals that the movie with the longest duration is Black Mirror: Bandersnatch, with a runtime of 312 minutes.

-- 6. Find Content Added in the Last 5 Years
SELECT *
FROM [dbo].[netflix_titles]
WHERE CAST ([date_added] as DATE) >= DATEADD(YEAR, -5, GETDATE());---DATEADD(interval, number, date)


--Objective
--To identify all content added to Netflix in the past five years, providing insights into the volume and trends of newly added content over this period.
--Result:
--Total Rows Retrieved: 3,260
--This indicates that Netflix added 3,260 pieces of content in the last 5 years.

--7a. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM [dbo].[netflix_titles]
WHERE [director] LIKE '%Rajiv Chilaka%';


--Objective: Retrieve all rows where Rajiv Chilaka is listed as a director, even if he shares the credit with other directors.
--Result: The query returns 22 rows, as it includes any content where Rajiv Chilaka appears in the director field, 
--regardless of whether he is the sole director or one of several directors.

--8. List All TV Shows with More Than 5 Seasons
SELECT *
FROM [dbo].[netflix_titles]
WHERE [type] = 'TV Show'
  AND CAST(SUBSTRING([duration], 1, CHARINDEX(' ', [duration]) - 1) AS INT) > 5;

  
--Objective: Identify TV shows with more than 5 seasons.
--The approach ensures that only the duration values expressed in terms of seasons are considered, ignoring those represented in minutes.
--Results:
--Total TV Shows with More Than 5 Seasons: 99 rows.
--This result reflects the TV shows in the database that have been explicitly labeled as having more than 5 seasons.

--9. Count the Number of Content Items in Each Genre (lised-in)

SELECT 
    TRIM(value) AS genre,
    COUNT(*) AS total_content
FROM [dbo].[netflix_titles]
CROSS APPLY STRING_SPLIT([listed_in], ',')
GROUP BY TRIM(value)
ORDER BY total_content DESC;
--Objective:
--To count the number of content items in each genre on Netflix 
--and sort the genres by the number of content items in descending order. 
--This query provides insight into which genres have the most content available on the platform.

--10. Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!

SELECT TOP 5
    [release_year],
    COUNT([show_id]) AS total_release,
    ROUND(
        CAST(COUNT([show_id]) AS FLOAT) /
        CAST(
		(SELECT COUNT([show_id]) 
		FROM [dbo].[netflix_titles] 
		WHERE [country] = 'India') AS FLOAT) * 100, 2
    ) AS avg_release
FROM [dbo].[netflix_titles]
WHERE [country] = 'India'
GROUP BY [release_year]
ORDER BY avg_release DESC;

--Objective: Calculate and rank years by the average number of content releases by India.

--11. List All Movies that are Documentaries
SELECT * 
FROM dbo.netflix_titles
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries';

--Objective: Retrieve 383 movies classified as documentaries.

--12. Find All Content Without a Director
SELECT * 
FROM netflix_titles
WHERE director IS NULL;

--Objective: List content that does not have a director (2634 ROWS).

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT COUNT(*) AS movies_count
FROM [dbo].[netflix_titles]
WHERE [cast] LIKE '%Salman Khan%'
  AND [release_year] >= YEAR(GETDATE()) - 10;

--Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT TOP 10
    actor,
    COUNT(*) AS movie_count
FROM (
    SELECT 
        TRIM(value) AS actor
    FROM [dbo].[netflix_titles]
    CROSS APPLY STRING_SPLIT([cast], ',')
    WHERE [country] = 'India'
) AS split_actors
GROUP BY actor
ORDER BY movie_count DESC;

--Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM [dbo].[netflix_titles]
) AS categorized_content
GROUP BY category;

--Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. 
--Count the number of items in each category.

--Findings and Conclusion
--Content Distribution: The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
--Common Ratings: Insights into the most common ratings provide an understanding of the content's target audience.
--Geographical Insights: The top countries and the average content releases by India highlight regional content distribution.
--Content Categorization: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.
--This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
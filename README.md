# NETFLIX Movies and TV Shows Data Analysis using SQL
![Netflix Logo](https://github.com/nphan91/NETFLIX-Data-Analysis/blob/main/logo.png)
# Overview: 
This project focuses on performing an in-depth analysis of Netflix's movies and TV shows dataset using SQL. The primary aim is to uncover meaningful insights and address key business-related queries derived from the data. This README outlines the project's purpose, business challenges, solutions, findings, and conclusions in detail.  

# Objectives  
- Examine the distribution of content types, such as movies and TV shows.  
- Determine the most frequent ratings for both movies and TV shows.  
- Analyze content trends based on release years, countries, and durations.  
- Investigate and classify content using specific criteria and keyword-based groupings.  
# Dataset
Link: https://github.com/nphan91/NETFLIX-Data-Analysis/blob/main/netflix_titles.csv

# Performance Analysis of Movies and TV Shows on Netflix 
### 1. Count the Number of Movies vs TV Shows
```sql
SELECT 
    [type],
    COUNT(*)
FROM [dbo].[netflix_titles]
GROUP BY [type];
```
## Objective: The aim of this analysis is to examine the distribution of content types (Movies vs TV Shows) in the Netflix catalog.  
By counting the number of occurrences of each content type, we can better understand the proportion of Movies and TV Shows available.
## Results:
# Movies: There are 6,131 Movies in the Netflix catalog.
# TV Shows: There are 2,676 TV Shows in the Netflix catalog.
# Implications:
# The data shows that Movies make up the larger portion of the content available on Netflix, with Movies outnumbering TV Shows by a significant margin (approximately 2.3 times more Movies than TV Shows).
# This distribution could indicate a greater focus on standalone films compared to episodic TV content

### 2. Find the Most Common Rating for Movies and TV Shows
```sql
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
```
## Objective: The goal of this analysis is to identify which rating appears most frequently for each content type (e.g., Movies and TV Shows) in the netflix_titles dataset. 
## Result: 
•	The analysis revealed that the most frequently occurring rating for both Movies and TV Shows in the dataset is TV-MA.
•	This finding suggests that content labeled as TV-MA (intended for mature audiences) is highly prevalent across both content types.

### 3. List All Movies Released in a Specific Year (e.g., 2020)
```sql
SELECT *
FROM [dbo].[netflix_titles]
WHERE [release_year] = '2020' AND [type] = 'Movie';
```
## Objective: The goal of this analysis is to retrieve all Movies that were released in the year 2020 on Netflix. 
This will help us examine the volume and distribution of Movies released in a specific year, providing insights into Netflix's content catalog for that time period.
## Results:
Total Movies Released in 2020: A total of 571 Movies were released on Netflix in the year 2020.

### 4. Find the Top 5 Countries with the Most Content on Netflix
```sql
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
```
## Objective: The goal is to identify the top 5 countries with the highest number of content items (movies, TV shows, etc.) available on Netflix. 
This analysis provides insight into the distribution of Netflix's content across various regions, helping to understand which countries dominate the platform in terms of content availability.
## Result: The following table presents the top 5 countries with the most content available on Netflix:
•	United States		3,690
•	India			1,046
•	United Kingdom	806
•	Canada		445
•	France			393


### 5. Identify the Longest Movie
```sql
SELECT *
FROM [dbo].[netflix_titles]
WHERE  [type] = 'Movie'
AND ISNUMERIC(REPLACE([duration], ' min', '')) = 1  -- Ensure only valid durations are considered
ORDER BY CAST(REPLACE([duration], ' min', '') AS INT) DESC;
```
## Objective:
•	The purpose of this query is to determine the movie with the longest duration on Netflix. 
•	By analyzing the dataset, we aim to identify which title has the highest runtime, ensuring that only valid numeric durations are considered.
•	The analysis reveals that the movie with the longest duration is Black Mirror: Bandersnatch, with a runtime of 312 minutes.

### 6. Find Content Added in the Last 5 Years
```sql
SELECT *
FROM [dbo].[netflix_titles]
WHERE CAST ([date_added] as DATE) >= DATEADD(YEAR, -5, GETDATE());---DATEADD(interval, number, date)
```
## Objective
To identify all content added to Netflix in the past five years, providing insights into the volume and trends of newly added content over this period.
## Result:
•	Total Rows Retrieved: 3,260
•	This indicates that Netflix added 3,260 pieces of content in the last 5 years.

### 7a. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
```sql
SELECT *
FROM [dbo].[netflix_titles]
WHERE [director] LIKE '%Rajiv Chilaka%';
```

## Objective: Retrieve all rows where Rajiv Chilaka is listed as a director, even if he shares the credit with other directors.
## Result: 
The query returns 22 rows, as it includes any content where Rajiv Chilaka appears in the director field, regardless of whether he is the sole director or one of several directors.

### 8. List All TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM [dbo].[netflix_titles]
WHERE [type] = 'TV Show'
  AND CAST(SUBSTRING([duration], 1, CHARINDEX(' ', [duration]) - 1) AS INT) > 5;
```
## Objective: Identify TV shows with more than 5 seasons.
The approach ensures that only the duration values expressed in terms of seasons are considered, ignoring those represented in minutes.
## Results:
Total TV Shows with More Than 5 Seasons: 99 rows.
This result reflects the TV shows in the database that have been explicitly labeled as having more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre (lised-in)
```sql
SELECT 
    TRIM(value) AS genre,
    COUNT(*) AS total_content
FROM [dbo].[netflix_titles]
CROSS APPLY STRING_SPLIT([listed_in], ',')
GROUP BY TRIM(value)
ORDER BY total_content DESC;
```
## Objective:
•	To count the number of content items in each genre on Netflix 
•	and sort the genres by the number of content items in descending order. 
•	This query provides insight into which genres have the most content available on the platform.


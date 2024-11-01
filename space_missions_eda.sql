------------------------------------------------
--| SPACE MISSIONS EXPLORATORY DATA ANALYSIS |--
------------------------------------------------





-- How many different companies deploy space missions?                                                                      -- 60 --
SELECT 
	COUNT(DISTINCT company)
FROM space_missions;





-- How many different companies have rockets that have not been retired.                                                     -- 36 --
SELECT 
	COUNT(DISTINCT company)
FROM space_missions
WHERE rocket_status <> 'Retired';





-- All missions that cost more than 50 million US dollars.
SELECT *
FROM space_missions
WHERE price IS NOT NULL
	AND price > 50;





-- How much has been spent total on space missions?                                                                          -- $162370 million --
SELECT 
	SUM(price)
FROM space_missions;





-- Who has launched the most space missions? 
-- How many missions has each company embarked on? 
-- How much money have they all spent on their missions?
SELECT 
	company,
	COUNT(*) mission_count,
	ROUND(SUM(price),2)::money AS total_spent
FROM space_missions
GROUP BY company
ORDER BY mission_count DESC;






-- Who has spent the most money on space missions and how much have they spent in total?                                    -- NASA: $75280 million --
WITH mission_money AS (SELECT 
							company,
							COUNT(*),
							ROUND(SUM(price),2)::money AS chaching
						FROM space_missions
						GROUP BY company)

SELECT 
	company AS space_geezus,
	chaching AS taxpayer_$$$
FROM mission_money
WHERE chaching = (SELECT MAX(chaching) FROM mission_money);





-- How many rockets are there here?                                                                                          -- 368 --
SELECT 
	COUNT(DISTINCT rocket)
FROM space_missions;





-- What are all the rocket names?
SELECT 
	DISTINCT rocket
FROM space_missions
WHERE rocket IS NOT NULL;







-- How have rocket launches trended across time? Has mission success rate increased?
------------------------------------------------------------------------------------
-- Trend of Rockets over time --
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date, 'MM/DD/YYYY')) AS launch_year,
    COUNT(*) AS total_launches
FROM space_missions
GROUP BY launch_year
ORDER BY launch_year;

-- Mission Success Rate over time --
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date, 'MM/DD/YYYY')) AS launch_year,
    COUNT(*) AS total_missions,
    SUM(CASE WHEN mission_status = 'Success' THEN 1 ELSE 0 END) AS successful_missions,
    (SUM(CASE WHEN mission_status = 'Success' THEN 1 ELSE 0 END)::FLOAT / COUNT(*)) * 100 AS success_rate
FROM space_missions
GROUP BY launch_year
ORDER BY launch_year;




SELECT *
FROM space_missions;



-- Which countries have had the most successful space missions? Has it always been that way?
--------------------------------------------------------------------------------------------
-- Countries with most successfull missions --
SELECT 
    REGEXP_REPLACE(location, '^.*,\s*', '') AS country,
    COUNT(*) AS successful_missions
FROM space_missions
WHERE mission_status = 'Success'
GROUP BY country
ORDER BY successful_missions DESC;


-- Trend of success rates over time --
SELECT 
    REGEXP_REPLACE(location, '^.*,\s*', '') AS country,
    EXTRACT(YEAR FROM TO_DATE(date, 'MM/DD/YYYY')) AS launch_year,
    COUNT(*) AS total_missions,
    SUM(CASE WHEN mission_status = 'Success' THEN 1 ELSE 0 END) AS successful_missions,
    (SUM(CASE WHEN mission_status = 'Success' THEN 1 ELSE 0 END)::FLOAT / COUNT(*)) * 100 AS success_rate
FROM space_missions
GROUP BY country, launch_year
ORDER BY country, launch_year;








-- Which rocket has been used for the most space missions? Is it still active?                                               -- Cosmos-3M (11K65M) |	446	| Retired --
WITH rocket_usage AS (SELECT 
        				rocket,
        				COUNT(*) AS mission_count,
        				MAX(rocket_status) AS current_status
    				  FROM space_missions
  					  GROUP BY rocket)
SELECT 
    rocket,
    mission_count,
    current_status
FROM rocket_usage
ORDER BY mission_count DESC
LIMIT 1;









-- Are there any patterns you can notice with the launch locations?
SELECT 
    location,
    COUNT(*) AS total_launches,
    SUM(CASE WHEN mission_status = 'Success' THEN 1 ELSE 0 END) AS successful_launches,
    (SUM(CASE WHEN mission_status = 'Success' THEN 1 ELSE 0 END)::FLOAT) / COUNT(*) * 100 AS success_rate
FROM space_missions
GROUP BY location
ORDER BY total_launches DESC;






-- Attempting to calculate the year-over-year growth rate of rocket launches.
WITH yearly_launches AS (SELECT 
        					EXTRACT(YEAR FROM TO_DATE(date, 'MM/DD/YYYY')) AS launch_year,
        					COUNT(*) AS total_launches
    					 FROM space_missions
    					 GROUP BY launch_year)

SELECT 
    launch_year,
    total_launches,
    LAG(total_launches) OVER (ORDER BY launch_year) AS previous_year_launches,
    (total_launches - LAG(total_launches) OVER (ORDER BY launch_year)) / NULLIF(LAG(total_launches) OVER (ORDER BY launch_year), 0) * 100 AS growth_rate
FROM yearly_launches;

USE citi;
GO

-- Insert data into table T1 from T2 (example, continue for each month)
INSERT INTO T1
SELECT *
FROM T2;
-- Repeat the above step for all 12 months

-- Confirm merging process was successful
SELECT COUNT(*) AS ALL_RECORDS
FROM T1;
GO

-- Create a view named 'distance'
CREATE VIEW distance AS
WITH clean_data AS
(
    SELECT 
        start_lat,
        start_lng,
        end_lat,
        end_lng,
        rideable_type,
        member_casual,
        LTRIM(RTRIM(start_station_name)) AS start_station_name,
        LTRIM(RTRIM(end_station_name)) AS end_station_name,
        CAST(started_at AS DATE) AS start_date,
        CAST(ended_at AS DATE) AS end_date,
        DATEPART(HOUR, started_at) AS start_hour,
        DATEPART(HOUR, ended_at) AS end_hour,
        DATENAME(WEEKDAY, started_at) AS weekday,
        DATENAME(MONTH, started_at) AS month,
        DATEDIFF(MINUTE, started_at, ended_at) AS duration,
        geography::Point(start_lat, start_lng, 4326).STDistance(geography::Point(end_lat, end_lng, 4326)) / 1000.0 AS distance
    FROM T1
    WHERE 
        start_lat IS NOT NULL
        AND start_lng IS NOT NULL
        AND end_lat IS NOT NULL
        AND end_lng IS NOT NULL
)
SELECT * FROM clean_data
WHERE duration > 0;
GO

-- Summary statistics for numerical columns
SELECT
    COUNT(*) AS total_records,
    AVG(duration) AS avg_duration,
    MIN(duration) AS min_duration,
    MAX(duration) AS max_duration,
    AVG(distance) AS avg_distance,
    MIN(distance) AS min_distance,
    MAX(distance) AS max_distance
FROM distance;
GO

-- Summary statistics by member type
SELECT
    member_casual,
    COUNT(*) AS total_records,
    AVG(duration) AS avg_duration,
    MIN(duration) AS min_duration,
    MAX(duration) AS max_duration,
    AVG(distance) AS avg_distance,
    MIN(distance) AS min_distance,
    MAX(distance) AS max_distance
FROM distance
GROUP BY member_casual;
GO

-- Monthly ride counts and average distance
SELECT
    month,
    COUNT(*) AS ride_count,
    AVG(distance) AS avg_distance
FROM distance
GROUP BY month
ORDER BY month;
GO

-- Monthly ride counts and average distance by member type
SELECT
    member_casual,
    month,
    COUNT(*) AS ride_count,
    AVG(distance) AS avg_distance
FROM distance
GROUP BY member_casual, month
ORDER BY member_casual, month;
GO

-- Hourly ride counts and average distance
SELECT
    start_hour,
    COUNT(*) AS ride_count,
    AVG(distance) AS avg_distance
FROM distance
GROUP BY start_hour
ORDER BY start_hour;
GO

-- Hourly ride counts and average distance by member type
SELECT
    member_casual,
    start_hour,
    COUNT(*) AS ride_count,
    AVG(distance) AS avg_distance
FROM distance
GROUP BY member_casual, start_hour
ORDER BY member_casual, start_hour;
GO

-- Weekday ride counts and average distance
SELECT
    weekday,
    COUNT(*) AS ride_count,
    AVG(distance) AS avg_distance
FROM distance
GROUP BY weekday
ORDER BY CASE 
    WHEN weekday = 'Sunday' THEN 1
    WHEN weekday = 'Monday' THEN 2
    WHEN weekday = 'Tuesday' THEN 3
    WHEN weekday = 'Wednesday' THEN 4
    WHEN weekday = 'Thursday' THEN 5
    WHEN weekday = 'Friday' THEN 6
    WHEN weekday = 'Saturday' THEN 7 
END;
GO

-- Weekday ride counts and average distance by member type
SELECT
    member_casual,
    weekday,
    COUNT(*) AS ride_count,
    AVG(distance) AS avg_distance
FROM distance
GROUP BY member_casual, weekday
ORDER BY member_casual, CASE 
    WHEN weekday = 'Sunday' THEN 1
    WHEN weekday = 'Monday' THEN 2
    WHEN weekday = 'Tuesday' THEN 3
    WHEN weekday = 'Wednesday' THEN 4
    WHEN weekday = 'Thursday' THEN 5
    WHEN weekday = 'Friday' THEN 6
    WHEN weekday = 'Saturday' THEN 7 
END;
GO

-- Count of rides by rideable type
SELECT
    rideable_type,
    COUNT(*) AS ride_count
FROM distance
GROUP BY rideable_type;
GO

-- Count of rides by rideable type and member type
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS ride_count
FROM distance
GROUP BY member_casual, rideable_type;
GO

-- Count of rides by member type
SELECT
    member_casual,
    COUNT(*) AS ride_count
FROM distance
GROUP BY member_casual;
GO

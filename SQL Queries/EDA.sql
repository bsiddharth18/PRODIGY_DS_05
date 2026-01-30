CREATE DATABASE accidents_analysis ;
USE accidents_analysis;

-- Cleaning
UPDATE us_accidents
SET Weather_Condition = CASE
    WHEN Weather_Condition = 'FALSE' THEN 0
    WHEN Weather_Condition = 'TRUE' THEN 1
    ELSE Weather_Condition
END;

-- Create table to import data in database
CREATE TABLE us_accidents_data (

    Severity INT ,

    Start_Time DATETIME,
    End_Time DATETIME,

    Start_Lat DECIMAL(9,6),
    Start_Lng DECIMAL(9,6),

    Distance_mi FLOAT,

    City VARCHAR(100),
    County VARCHAR(100),
    State VARCHAR(50),
    Zipcode VARCHAR(20),
    Country VARCHAR(50),
    Timezone VARCHAR(50),
    Airport_Code  VARCHAR(50), 

    Temperature_F FLOAT,
    Wind_Chill_F FLOAT,
    Humidity_per FLOAT,
    Visibility_mi FLOAT,
    Wind_Speed_mph FLOAT,

    Weather_Condition VARCHAR(100),

    Crossing VARCHAR(50),
    Junction VARCHAR(50),
    No_Exit VARCHAR(50),
    Railway VARCHAR(50),
    Station VARCHAR(50),
    Stop VARCHAR(50),
    Traffic_Calming VARCHAR(50),
    Traffic_Signal VARCHAR(50),
    Turning_loop VARCHAR(50),
    Nautical_Twilight VARCHAR(50)
);
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

-- DATA Importing 
LOAD DATA LOCAL INFILE
'C:/Users/siddharth bhagwat/Documents/PRODIGY_DS_05/Data/cleaned_US_Accidents.csv'
INTO TABLE us_accidents_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;

-- EDA
select * from us_accidents_data limit 200;

-- Severity 
SELECT 
    CASE Severity 
		WHEN 1 THEN 'Minor impact'
        WHEN 2 THEN 'Moderate impact'
        WHEN 3 THEN 'High impact'
        WHEN 4 THEN 'Severe impact'
	END AS Severity,
    COUNT(*) AS total_accidents 
FROM us_accidents_data 
GROUP BY Severity 
ORDER BY total_accidents DESC ;

-- Conclusion: Most of casualities impacted moderate to high

-- Top 10 cities by casuality
SELECT
	City,
    COUNT(*) AS Total_count
FROM us_accidents_data
GROUP BY City
ORDER BY Total_count DESC
LIMIT 10
;

-- Infrastructure Risk Analysis



SELECT
    Severity,

    ROUND(
        100.0 * Turning_loop / NULLIF(Turning_loop + No_Turning_loop, 0),
        2
    ) AS chances_at_turning_loop,

    ROUND(
        100.0 * Station / NULLIF(Station + No_Station, 0),
        2
    ) AS chances_At_station,

    ROUND(
        100.0 * Junction / NULLIF(Junction + No_Junction, 0),
        2
    ) AS chances_due_to_junction,

    ROUND(
        100.0 * Traffic_Signal / NULLIF(Traffic_Signal + No_Traffic_Signal, 0),
        2
    ) AS chances_Traffic_Signal

FROM (
    SELECT 
        CASE Severity 
            WHEN 1 THEN 'Minor impact'
            WHEN 2 THEN 'Moderate impact'
            WHEN 3 THEN 'High impact'
            WHEN 4 THEN 'Severe impact'
        END AS Severity,

        SUM(CASE WHEN Turning_loop = 'TRUE' THEN 1 ELSE 0 END) AS Turning_loop,
        SUM(CASE WHEN Turning_loop = 'FALSE' THEN 1 ELSE 0 END) AS No_Turning_loop,

        SUM(CASE WHEN Station = 'TRUE' THEN 1 ELSE 0 END) AS Station,
        SUM(CASE WHEN Station = 'FALSE' THEN 1 ELSE 0 END) AS No_Station,

        SUM(CASE WHEN Junction = 'TRUE' THEN 1 ELSE 0 END) AS Junction,
        SUM(CASE WHEN Junction = 'FALSE' THEN 1 ELSE 0 END) AS No_Junction,

        SUM(CASE WHEN Traffic_Signal = 'TRUE' THEN 1 ELSE 0 END) AS Traffic_Signal,
        SUM(CASE WHEN Traffic_Signal = 'FALSE' THEN 1 ELSE 0 END) AS No_Traffic_Signal

    FROM us_accidents_data
    GROUP BY Severity
) t;

-- A larger proportion of minor and moderate accidents occur at turning loops and junctions 
-- compared to high and severe accidents. However, this analysis reflects feature 
-- distribution within severity levels and does not measure the risk of severity given the presence of these features.

WITH base AS (
    SELECT
        Severity,
        Turning_loop,
        Junction,
        Station,
        Traffic_Signal
    FROM us_accidents_data
),

severe_flags AS (
    SELECT
        *,
        CASE WHEN Severity = 4 THEN 1 ELSE 0 END AS is_severe
    FROM base
)

SELECT
    feature,

    ROUND(
        100.0 * SUM(CASE WHEN feature_value = 'TRUE' AND is_severe = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN feature_value = 'TRUE' THEN 1 ELSE 0 END), 0),
        2
    ) AS severe_pct_when_true,

    ROUND(
        100.0 * SUM(CASE WHEN feature_value = 'FALSE' AND is_severe = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN feature_value = 'FALSE' THEN 1 ELSE 0 END), 0),
        2
    ) AS severe_pct_when_false,

    ROUND(
        (
            1.0 * SUM(CASE WHEN feature_value = 'TRUE' AND is_severe = 1 THEN 1 ELSE 0 END)
            / NULLIF(SUM(CASE WHEN feature_value = 'TRUE' THEN 1 ELSE 0 END), 0)
        )
        /
        NULLIF(
            1.0 * SUM(CASE WHEN feature_value = 'FALSE' AND is_severe = 1 THEN 1 ELSE 0 END)
            / NULLIF(SUM(CASE WHEN feature_value = 'FALSE' THEN 1 ELSE 0 END), 0),
        0),
        2
    ) AS risk_ratio

FROM (
    SELECT 'Turning_loop' AS feature, Turning_loop AS feature_value, is_severe
    FROM severe_flags

    UNION ALL
    SELECT 'Junction', Junction, is_severe
    FROM severe_flags

    UNION ALL
    SELECT 'Station', Station, is_severe
    FROM severe_flags

    UNION ALL
    SELECT 'Traffic_Signal', Traffic_Signal, is_severe
    FROM severe_flags
) f

GROUP BY feature
ORDER BY risk_ratio DESC;

-- 1. Severe crashes are less likely in the presence of junctions, stations, turning loops, and traffic signals, with all features 
-- showing risk ratios below 1.0 and severe rates of 0.00%–0.03% versus ~0.06% when absent.

-- 2. These findings are correlational and limited by the rarity of severe cases (<0.1%) and unmeasured confounders 
-- (e.g., speed, road type, traffic volume, weather), so causal claims require multivariate and statistical validation.


	
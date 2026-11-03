-- Filtering and selection 
-- Find all disaster events that lasted more than 100 days

select disaster_event_id from dw.fact_disaster_event
where duration_days > 100;

-- Retrieve all disasters where a very large number of people were affected (e.g., more than 1 million).

select disaster_event_id from dw.fact_disaster_event
where population_effected > 1000000;

-- List all countries whose names start with the letter “A”.

select country_location_name from dw.dim_location
where country_location_name like 'A%'

-- Find all disaster events where the severity value is missing.
select disaster_event_id from dw.fact_disaster_event
where severity is null

-- Retrieve all records where the alert level is “High”.
select alert_id from dw.dim_alert
where alert_level = 'Red'

-- Find all disaster events that lasted more than 200 days but less than 500 days, and also affected more than 100,000 people.
select disaster_event_id from dw.fact_disaster_event
where duration_days between 200 and 500 AND population_effected > 100000;

-- Retrieve all disaster events where the duration is greater than the average duration of all disasters.
select disaster_event_id from dw.fact_disaster_event
where duration_days > ( select AVG(duration_days) from dw.fact_disaster_event)

-- Find all disaster events where the population affected is among the top 5 highest values.
select disaster_event_id from dw.fact_disaster_event
where population_effected in (select population_effected from dw.fact_disaster_event order by population_effected desc limit 5)

-- Find all disaster events where the duration is greater than 100 days and the severity is not null, and sort them by severity in descending order.
select disaster_event_id from dw.fact_disaster_event
where duration_days > 100 and severity is not null
order by severity DESC

-- Find all disaster events where severity is greater than 50,000 AND population affected is less than 100,000 AND duration is not between 50 and 200 days
select disaster_event_id, severity, population_effected, duration_days
from dw.fact_disaster_event
where severity > 50000 and population_effected < 100000 and duration_days not between 50 and 200;

-- Retrieve disaster events that have very long durations (e.g., more than 300 days) AND belong to the top 10% in terms of population affected
select disaster_event_id from dw.fact_disaster_event
where duration_days > 300 and population_effected >= (select PERCENTILE_CONT(0.9) within group (order by population_effected) from dw.fact_disaster_event )

-- Find disaster events whose severity is higher than the average severity of all disasters.
select disaster_event_id, severity from dw.fact_disaster_event
where severity > (select AVG(severity) FROM dw.fact_disaster_event )
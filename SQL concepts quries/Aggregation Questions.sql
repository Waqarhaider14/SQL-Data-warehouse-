-- BASIC AGGREGATION QUESTIONS

-- Count how many disasters events are recorded in total
select count(disaster_event_id) from dw.fact_disaster_event

-- Find the total number of disasters for each country.
select dl.country_location_name, count(df.disaster_event_id) as Disaster_count_per_country from dw.fact_disaster_event df join dw.dim_location dl on df.location_id = dl.location_id
group by dl.country_location_name
order by count(df.disaster_event_id) desc

--Calculate the average duration of disasters.
select ROUND(avg(duration_days), 2) as average_duration from dw.fact_disaster_event

--Find the maximum duration of any disaster event.
select MAX(duration_days) as max_duration from dw.fact_disaster_event

-- Find the disaster event having max duration count and which disaster type have max duration days
select max(df.duration_days), df.disaster_event_id, de.event_type, max(df.duration_days) from dw.fact_disaster_event df join dw.dim_event_type de
on df.event_type_id = de.event_type_id
where df.duration_days = (select max(duration_days) from dw.fact_disaster_event )
group by df.disaster_event_id, de.event_type

-- Find the minimum population affected across all disasters.
select min(population_effected) as min_population_effected from dw.fact_disaster_event

-- Find the minimum population accross disaster and which disaster event id have & which event type
select min(df.population_effected), df.disaster_event_id, de.event_type
from dw.fact_disaster_event df join dw.dim_event_type de
on df.event_type_id = de.event_type_id
where df.population_effected = (select min(population_effected) from dw.fact_disaster_event)
group by df.disaster_event_id, de.event_type_id
 
-- Count how many disaster events have missing severity values.
select count(disaster_event_id) from dw.fact_disaster_event
where severity is null

-- Find the total population affected across all disasters.
select sum(population_effected) from dw.fact_disaster_event

-- Get the number of disaster for each alert level
select da.alert_level, count(df.disaster_event_id)
from dw.fact_disaster_event df join dw.dim_alert da
on df.alert_id = da.alert_id
group by da.alert_level
order by count(df.disaster_event_id) DESC

-- Find the average severity for all disasters.
select round(avg(severity),3) from dw.fact_disaster_event

-- Count how many disasters occurred for each disaster type.
select de.event_type, count(df.disaster_event_id)
from dw.fact_disaster_event df join dw.dim_event_type de
on df.event_type_id = de.event_type_id
group by de.event_type_id
order by count(df.disaster_event_id) DESC

-- INTERMEDIATE AGGREGATION QUESTIONS

-- Find the total number of disasters for each country, but only include countries with more than 10 disasters.
select dl.country_location_name, count(df.disaster_event_id) 
from dw.fact_disaster_event df join dw.dim_location dl
on df.location_id = dl.location_id
group by dl.country_location_name
having count(df.disaster_event_id) > 10
order by count(df.disaster_event_id) desc;

-- Calculate the average duration of disasters for each disaster type.
select de.event_type, round(avg(df.duration_days),2) as avg_duration
from dw.fact_disaster_event df join dw.dim_event_type de
on df.event_type_id = de.event_type_id
group by de.event_type
having round(avg(df.duration_days),2) is not null

-- Find countries where the total affected population exceeds 1 million.
select dl.country_location_name, sum(df.population_effected)
from dw.fact_disaster_event df join dw.dim_location dl
on df.location_id = dl.location_id 
group by dl.country_location_name 
having sum(df.population_effected) > 1000000

-- Get the maximum severity recorded for each disaster type.
select de.event_type, round(max(df.severity),2) 
from dw.fact_disaster_event df join dw.dim_event_type de
on df.event_type_id = de.event_type_id
group by event_type

-- Find the average population affected per disaster type, excluding very small events (e.g., less than 1000 people).
select de.event_type, round(avg(df.population_effected),2) as avg_population
from dw.fact_disaster_event df join dw.dim_event_type de
on df.event_type_id = de.event_type_id 
where df.population_effected >= 1000
group by de.event_type

-- Count how many disasters fall into each alert level, but only show levels with more than 200 events.
select da.alert_level, count(df.disaster_event_id)
from dw.fact_disaster_event df join dw.dim_alert da
on df.alert_id = da.alert_id
group by da.alert_level
having count(df.disaster_event_id) > 200

-- Find the number of disasters per year.
select dd.year, count(df.disaster_event_id)
from dw.fact_disaster_event df join dw.dim_date dd
on df.start_date_id = dd.date_id
group by dd.year
order by dd.year

-- Calculate the total population affected per country per year
select dd.year, dl.country_location_name, sum(df.population_effected)
from dw.fact_disaster_event df 
join dw.dim_location dl 
on df.location_id = dl.location_id 
join dw.dim_date dd
on df.start_date_id = dd.date_id
group by dl.country_location_name, dd.year

-- Calculate the percentage contribution of each disaster type to the total number of disasters.
select de.event_type,     ROUND(
        COUNT(DISTINCT disaster_event_id) * 100.0 
        / SUM(COUNT(DISTINCT disaster_event_id)) over(),2
    ) AS percentage
from dw.fact_disaster_event df join dw.dim_event_type de
on df.event_type_id = de.event_type_id
group by de.event_type
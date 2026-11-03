-- LEFT JOIN 
-- Find all countries and the number of disasters in each country, including countries where no disasters occurred
select dl.country_location_name, count(df.disaster_event_id)
from dw.dim_location dl LEFT JOIN dw.fact_disaster_event df
on dl.location_id = df.location_id
group by dl.country_location_name

-- Retrieve all disaster events along with their alert levels, but also include events where alert information is missing.
select df.disaster_event_id, da.alert_level
from dw.fact_disaster_event df LEFT JOIN dw.dim_alert da
on df.alert_id = da.alert_id

-- Find all countries where no disaster has occurred.
select dl.country_location_name, count(df.disaster_event_id)
from dw.dim_location dl LEFT JOIN dw.fact_disaster_event df
on dl.location_id = df.location_id
group by dl.country_location_name
having count(df.disaster_event_id) = 0

/*Find all countries along with total disasters, and show only those countries 
where the total disasters are below the average disaster count across all countries (including zero).*/
select dl.country_location_name, count(df.disaster_event_id) 
from dw.dim_location dl LEFT JOIN dw.fact_disaster_event df
on dl.location_id = df.location_id
group by dl.country_location_name
having count(df.disaster_event_id) < (select avg(cnt)
										from (select dl1.country_location_name, count(df1.disaster_event_id) as cnt
											from dw.dim_location dl1 LEFT JOIN dw.fact_disaster_event df1
											on dl1.location_id = df1.location_id
											group by dl1.country_location_name)sub );

/* Retrieve all disaster events with their location details, and filter only those events where population affected is above average, 
while still including events that have missing location data. */

select df.disaster_event_id, dl.country_location_name
from dw.fact_disaster_event df LEFT JOIN dw.dim_location dl
on df.location_id = dl.location_id
where df.population_effected > (select avg(population_effected) from dw.fact_disaster_event)

-- Find all countries and calculate the percentage contribution of disasters per country, including countries with zero disasters.
select dl.country_location_name, round(count(disaster_event_id) * 100.0 / sum(count(disaster_event_id)) over(), 2) as percentage_contribution
from dw.dim_location dl LEFT JOIN dw.fact_disaster_event df
on dl.location_id = df.location_id
group by dl.country_location_name
order by round(count(disaster_event_id) * 100.0 / sum(count(disaster_event_id)) over(), 2) desc

-- RIGHT JOIN

--Retrieve all disaster types and show the top 3 highest duration disasters per type, including types with no disasters.
select de.event_type, df.disaster_event_id, df.duration_days
from dw.fact_disaster_event df RIGHT JOIN dw.dim_event_type de
on df.event_type_id = de.event_type_id
where df.duration_days is not null
order by df.duration_days desc
limit 3;

--Find mismatched data between disaster events and location records (i.e., events without location and locations without events), and count them separately.

select count(case when df.disaster_event_id is null then 1 end) as null_disaster_count,
		count(case when dl.country_location_name is null then 1 end) as null_location_count

from dw.fact_disaster_event df FULL OUTER JOIN dw.dim_location dl
ON df.location_id = dl.location_id
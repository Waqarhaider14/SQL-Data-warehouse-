-- CTEs
/* Create a CTE that calculates the total number of disasters for each country.
 Then use that CTE to retrieve only countries where the disaster count is greater than 100.*/
with disaster_country_cnt as (
		 select dl.country_location_name, count(df.disaster_event_id) as cnt
		 from dw.fact_disaster_event df join dw.dim_location dl
		 on df.location_id = dl.location_id
		 group by dl.country_location_name
		 )
select * from disaster_country_cnt
where cnt > 100;

/*Create a CTE that filters disaster events with duration greater than 100 days.
From that CTE, retrieve all records sorted by duration in descending order.*/
with disaster_duration as (
			select disaster_event_id, duration_days
			from dw.fact_disaster_event
			where duration_days > 100
			)
select * from disaster_duration

/*Create a CTE that calculates the average population affected across all disasters.
Then use that CTE to retrieve disaster events where the population affected is greater than this average.*/
with avg_disaster_population as (
			select avg(population_effected) as average_population
			from dw.fact_disaster_event
			)
select disaster_event_id
from dw.fact_disaster_event
where population_effected > (select average_population from avg_disaster_population)
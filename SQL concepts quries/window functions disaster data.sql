-- For each disaster event, assign a sequential row number based on the disaster's duration, starting with the longest-duration disaster as number 1.
select df.disaster_event_id, dl.country_location_name, df.duration_days, row_number() over (order by df.duration_days DESC) as row_sequence
from dw.fact_disaster_event df inner join dw.dim_location dl
on df.location_id = dl.location_id
where duration_days is not null;

-- Rank all disaster events based on the number of people affected, with the disaster affecting the most people receiving rank 1.

select df.disaster_event_id, dl.country_location_name, df.population_effected, rank() over (order by df.population_effected desc) as rank_wise_effected
from dw.fact_disaster_event df inner join dw.dim_location dl
on df.location_id = dl.location_id
where df.population_effected is not null;


-- Rank all disaster events based on severity, from highest to lowest, using dense ranking so that tied severity values receive the same rank without gaps.

select df.disaster_event_id, dl.country_location_name, df.severity, dense_rank() over (order by df.severity desc) as rank_wise_severity
from dw.fact_disaster_event df inner join dw.dim_location dl
on df.location_id = dl.location_id

-- For each year calculate the population effected
select dd.year, sum(df.population_effected) as total_population
from dw.fact_disaster_event df inner join dw.dim_date dd
on df.start_date_id = dd.date_id
where df.population_effected is not null
group by dd.year
order by dd.year

-- For each disaster event, show the population affected by the previous disaster event when events are ordered by their start date.

select df.disaster_event_id, dd.full_date, df.population_effected, lag(df.population_effected) over (order by dd.full_date, df.fact_id) as previous_event_population
from dw.fact_disaster_event df inner join dw.dim_date dd
on df.start_date_id = dd.date_id
where df.population_effected is not null

-- For each year calculate the population effected and also show previous year population effected count
select dd.year, sum(df.population_effected), lag(sum(df.population_effected)) over (order by dd.year) as previous_year_population
from dw.fact_disaster_event df inner join dw.dim_date dd
on df.start_date_id = dd.date_id
where df.population_effected is not null
group by dd.year;

-- For each disaster event, show the population affected by the next disaster event when events are ordered by their start date.
select df.disaster_event_id, dd.full_date, df.population_effected, lead(df.population_effected) over (order by dd.full_date, df.fact_id) as next_event_population
from dw.fact_disaster_event df inner join dw.dim_date dd
on df.start_date_id = dd.date_id
where df.population_effected is not null

-- For each year calculate the population effected and also show next year population effected count
select dd.year, sum(df.population_effected), lead(sum(df.population_effected)) over (order by dd.year) as post_year_population
from dw.fact_disaster_event df inner join dw.dim_date dd
on df.start_date_id = dd.date_id
where df.population_effected is not null
group by dd.year;

-- For each country, assign a sequential number to its disaster events based on population affected, with the disaster affecting the most people receiving number 1.
select dl.country_location_name, df.population_effected, row_number() over (partition by dl.country_location_name order by df.population_effected desc) as rank_wise_effected
from dw.fact_disaster_event df inner join dw.dim_location dl
on df.location_id = dl.location_id
where df.population_effected is not null;

-- For each country, rank its disaster events based on duration, from longest to shortest. If two disasters have the same duration, they should receive the same rank.
select df.disaster_event_id, dl.country_location_name, df.duration_days, rank() over (partition by dl.country_location_name order by df.duration_days desc ) as rnk
from dw.fact_disaster_event df inner join dw.dim_location dl
on df.location_id = dl.location_id
where df.duration_days is not null

-- For each country, show the population affected by the previous disaster in that country, ordering disasters by their start date.
select dl.country_location_name, dd.full_date, df.population_effected, LAG(df.population_effected) over (partition by dl.country_location_name order by dd.full_date, df.fact_id) as previous_event_population
from dw.fact_disaster_event df inner join dw.dim_location dl
	on df.location_id = dl.location_id
INNER JOIN dw.dim_date dd
    ON df.start_date_id = dd.date_id
where df.population_effected is not null;

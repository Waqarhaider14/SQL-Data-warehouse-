/*
-> Disasters by Event Type
select de.event_type, count(*) as Total_disasters
from dw.fact_disaster_event df
join dw.dim_event_type de
on df.event_type_id = de.event_type_id
group by event_type

->Disasters by Country
select country_location_name, count(*) as Total_disaster
from dw.fact_disaster_event df
join dw.dim_location dl
on df.location_id = dl.location_id
group by country_location_name
order by Total_disaster DESC

->Disasters by year
select year, count(*) as Total_disasters
from dw.fact_disaster_event df
join dw.dim_date dd
on df.End_date_id = dd.date_id
group by year
order by year DESC

->Top 10 disaster-prone countries
select country_location_name, count(*) as Total_disaster
from dw.fact_disaster_event df
join dw.dim_location dl
on df.location_id = dl.location_id
group by country_location_name
order by Total_disaster DESC
Limit 10;

-> Total deaths by Flood
select SUM(death) as Total_deaths_by_flood
from dw.fact_disaster_event df
join dw.dim_event_type de
on df.event_type_id = de.event_type_id
where event_type = 'FL'

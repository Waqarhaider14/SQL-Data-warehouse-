-- CASE...WHEN
/* Classify disaster events into three categories based on duration:

Short (≤ 100 days)
Medium (101–300 days)
Long (> 300 days)
Then count how many disasters fall into each category.*/

select 
	case when duration_days <= 100 then 'short'
		 when duration_days between 101 and 300 then 'Medium'
		 else 'long'
		 end as duration_category,
		 count(*)
	from dw.fact_disaster_event
	group by duration_category

/*Create a new column that labels disasters as:

“High Impact” if population affected is greater than 500,000
“Moderate Impact” if between 100,000 and 500,000
“Low Impact” otherwise
Then retrieve all disaster events along with this new category.*/

select disaster_event_id,
		case when population_effected > 500000 then 'High Impact' 
			 when population_effected between 100000 and 500000 then 'Moderate Impact'
			 else 'Low Impact'
			 end as Population_category
		from dw.fact_disaster_event

/*For each country, calculate:

total number of disasters
number of high severity disasters (e.g., severity > 50,000)*/

select dl.country_location_name, count(df.disaster_event_id),
		count(case when df.severity > 50000 then 1 end) as high_severity_count
from dw.fact_disaster_event df join dw.dim_location dl
on df.location_id = dl.location_id
group by dl.country_location_name




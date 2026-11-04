INSERT INTO dw.dim_drought (
    disaster_event_id,
    drought_type,
    effected_area_km2
)
SELECT DISTINCT
    d.disaster_event_id,
    d.drought_type,
    d.effected_area_km2
FROM src.drought d
JOIN dw.fact_disaster_event fd
ON d.disaster_event_id = fd.disaster_event_id;

INSERT INTO dw.dim_tropical_cyclone (
    disaster_event_id,
    cyclone_name,
    maximum_wind_speed,
    category,
    vulnerability
)
SELECT DISTINCT
    tc.disaster_event_id,
    tc.cyclone_name,
    tc.maximum_wind_speed,
    tc.category,
    tc.vulnerability
FROM src.tropical_cyclone tc
JOIN dw.fact_disaster_event fd
ON tc.disaster_event_id = fd.disaster_event_id;


INSERT INTO dw.dim_volcano (
    disaster_event_id,
    volcano_name,
    volcano_number,
    volcano_explosivity_index,
    population_exposure_index
)
SELECT DISTINCT
    ve.disaster_event_id,
    ve.volcano_name,
    ve.volcano_number,
    ve.volcano_explosivity_index,
    ve.population_exposure_index
FROM src.volcano_eruption ve
JOIN dw.fact_disaster_event df
ON ve.disaster_event_id = df.disaster_event_id;

INSERT INTO dw.dim_wild_fire (
    disaster_event_id,
    burned_area
)
SELECT DISTINCT
    wf.disaster_event_id,
    wf.burned_area
FROM src.wild_fire wf
JOIN dw.fact_disaster_event fd
ON wf.disaster_event_id = fd.disaster_event_id;

insert into dw.dim_flood (
    disaster_event_id,
    gdacs_id,
    death,
    displaced
)
SELECT DISTINCT
    f.disaster_event_id,
    f.gdacs_id,
    f.death,
    f.displaced
FROM src.flood f
JOIN dw.fact_disaster_event fd  
ON f.disaster_event_id = fd.disaster_event_id;
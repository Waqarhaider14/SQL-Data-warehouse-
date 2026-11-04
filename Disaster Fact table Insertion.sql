INSERT INTO dw.fact_disaster_event (
    disaster_event_id,
    event_type_id,
    location_id,
    alert_id,
    source_id,
    start_date_id,
    end_date_id,
    severity,
    duration_days,
    population_effected,
    death,
    displaced,
    effected_area_km2
)
SELECT
    s.disaster_event_id,

    et.event_type_id,
    l.location_id,
    a.alert_id,
    so.source_id,

    sd.date_id AS start_date_id,
    ed.date_id AS end_date_id,

    MAX(s.severity)                 AS severity,
    MAX(s.duration_days)::INT      AS duration_days,
    SUM(s.population_effected)     AS population_effected,
    SUM(s.death)                   AS death,
    SUM(s.displaced)               AS displaced,
    SUM(s.effected_area_km2)       AS effected_area_km2

FROM (

    -- Normalize all disaster tables into ONE stream
SELECT
    disaster_event_id,
    event_type,
    country_location,
    iso3,
    alert_level,
    alert_score,
    episode_alert_level,
    episode_alert_score,
    source_system,
    from_date,
    to_date,
    severity,
    duration_days::INT            AS duration_days,
    NULL::INT                     AS population_effected,
    NULL::INT                     AS death,
    NULL::INT                     AS displaced,
    effected_area_km2::INT        AS effected_area_km2
FROM src.drought

UNION ALL
SELECT
    disaster_event_id,
    event_type,
    country_location,
    iso3,
    alert_level,
    alert_score,
    episode_alert_level,
    episode_alert_score,
    source_system,
    from_date,
    to_date,
    severity,
    NULL::INT 					  AS duration_days,
    population_effected,
    NULL::INT                     AS death,
    NULL::INT                     AS displaced,
    NULL:: INT                    AS effected_area_km2
FROM src.earthquake

UNION ALL
SELECT
    disaster_event_id,
    event_type,
    country_location,
    iso3,
    alert_level,
    alert_score,
    episode_alert_level,
    episode_alert_score,
    source_system,
    from_date,
    to_date,
    severity,
    NULL::INT 					  AS duration_days,
    NULL::INT                     AS population_effected,
    death,
    displaced,
    NULL:: INT                    AS effected_area_km2
FROM src.flood

UNION ALL
SELECT
    disaster_event_id,
    event_type,
    country_location,
    iso3,
    alert_level,
    alert_score,
    episode_alert_level,
    episode_alert_score,
    source_system,
    from_date,
    to_date,
    severity,
    duration_days,
    population_effected,
    NULL::INT                     AS death,
    NULL::INT                     AS displaced,
    NULL:: INT                    AS effected_area_km2
FROM src.wild_fire

UNION ALL
SELECT
    disaster_event_id,
    event_type,
    country_location,
    iso3,
    alert_level,
    alert_score,
    episode_alert_level,
    episode_alert_score,
    source_system,
    from_date,
    to_date,
    severity,
    NULL::INT 					  AS duration_days,
    population_effected,
    NULL::INT                     AS death,
    NULL::INT                     AS displaced,
    NULL:: INT                    AS effected_area_km2
FROM src.volcano_eruption

UNION ALL
SELECT
    disaster_event_id,
    event_type,
    country_location,
    iso3,
    alert_level,
    alert_score,
    episode_alert_level,
    episode_alert_score,
    source_system,
    from_date,
    to_date,
    severity,
    NULL::INT 					  AS duration_days,
    NULL::INT                     AS population_effected,
    NULL::INT                     AS death,
    NULL::INT                     AS displaced,
    NULL:: INT                    AS effected_area_km2
FROM src.tropical_cyclone


) s

JOIN dw.dim_event_type et
    ON s.event_type = et.event_type

JOIN dw.dim_location l
    ON s.country_location = l.country_location_name
   AND s.iso3 = l.iso3

JOIN dw.dim_source so
    ON s.source_system = so.source_system

JOIN dw.dim_alert a
    ON s.alert_level = a.alert_level
   AND s.alert_score = a.alert_score
   AND s.episode_alert_level = a.episode_alert_level
   AND s.episode_alert_score = a.episode_alert_score

JOIN dw.dim_date sd
    ON s.from_date = sd.full_date

JOIN dw.dim_date ed
    ON s.to_date = ed.full_date

GROUP BY
    s.disaster_event_id,
    et.event_type_id,
    l.location_id,
    a.alert_id,
    so.source_id,
    sd.date_id,
    ed.date_id
	
ON CONFLICT (disaster_event_id) DO NOTHING; 
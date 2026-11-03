CREATE TABLE dw.dim_date (
    date_id        SERIAL PRIMARY KEY,
    full_date      DATE NOT NULL UNIQUE,
    year           INT,
    quarter        INT,
    month          INT,
    month_name     TEXT,
    day            INT,
    day_of_week    INT,
    day_name       TEXT
);

CREATE TABLE dw.dim_location (
    location_id     SERIAL PRIMARY KEY,
    country_location_name    TEXT NOT NULL,
    iso3            TEXT,
    UNIQUE (country_location_name, iso3)
);

CREATE TABLE dw.dim_event_type (
    event_type_id   SERIAL PRIMARY KEY,
    event_type      TEXT NOT NULL UNIQUE
);

CREATE TABLE dw.dim_alert (
    alert_id                SERIAL PRIMARY KEY,
    alert_level             TEXT,
    alert_score             INT,
    episode_alert_level     TEXT,
    episode_alert_score     DECIMAL,
    impact_level            TEXT,
    impact_category         TEXT
);

CREATE TABLE dw.dim_source (
    source_id       SERIAL PRIMARY KEY,
    source_system   TEXT NOT NULL UNIQUE
);

CREATE TABLE dw.fact_disaster_event (
    fact_id             BIGSERIAL PRIMARY KEY,

    disaster_event_id   TEXT NOT NULL,

    event_type_id       INT REFERENCES dw.dim_event_type(event_type_id),
    location_id         INT REFERENCES dw.dim_location(location_id),
    alert_id            INT REFERENCES dw.dim_alert(alert_id),
    source_id           INT REFERENCES dw.dim_source(source_id),

    start_date_id       INT REFERENCES dw.dim_date(date_id),
    end_date_id         INT REFERENCES dw.dim_date(date_id),

    -- Measures
    severity                    DECIMAL,
    duration_days               INT,
    population_effected         INT,
    death                       INT,
    displaced                   INT,
    effected_area_km2           INT,

    UNIQUE (disaster_event_id)
);

CREATE TABLE dw.dim_drought (
    disaster_event_id   TEXT PRIMARY KEY,
    drought_type        TEXT,

    FOREIGN KEY (disaster_event_id)
        REFERENCES dw.fact_disaster_event(disaster_event_id)
);

CREATE TABLE dw.dim_earthquake (
    disaster_event_id       TEXT PRIMARY KEY,
    earthquake_magnitude    TEXT,
    depth_km                TEXT,

    FOREIGN KEY (disaster_event_id)
        REFERENCES dw.fact_disaster_event(disaster_event_id)
);

CREATE TABLE dw.dim_flood (
    disaster_event_id   TEXT PRIMARY KEY,
    gdacs_id            TEXT,

    FOREIGN KEY (disaster_event_id)
        REFERENCES dw.fact_disaster_event(disaster_event_id)
);

CREATE TABLE dw.dim_wild_fire (
    disaster_event_id   TEXT PRIMARY KEY,
    burned_area         TEXT,

    FOREIGN KEY (disaster_event_id)
        REFERENCES dw.fact_disaster_event(disaster_event_id)
);

CREATE TABLE dw.dim_volcano (
    disaster_event_id               TEXT PRIMARY KEY,
    volcano_name                    TEXT,
    volcano_number                  TEXT,
    volcano_explosivity_index       TEXT,
    population_exposure_index       TEXT,

    FOREIGN KEY (disaster_event_id)
        REFERENCES dw.fact_disaster_event(disaster_event_id)
);

CREATE TABLE dw.dim_tropical_cyclone (
    disaster_event_id       TEXT PRIMARY KEY,
    cyclone_name            TEXT,
    maximum_wind_speed      TEXT,
    category                TEXT,
    vulnerability           TEXT,

    FOREIGN KEY (disaster_event_id)
        REFERENCES dw.fact_disaster_event(disaster_event_id)
);

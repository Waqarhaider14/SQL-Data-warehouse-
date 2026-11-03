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
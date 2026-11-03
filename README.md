# Global Disaster Events (2000–2025) — SQL Data Warehouse

A PostgreSQL data warehouse built on top of global natural-disaster event data for the period 2000–2025. Six disaster-specific source tables are normalized into one fact table (`dw.fact_disaster_event`) surrounded by shared dimension tables, plus one subtype dimension per disaster type. The project also contains analytical SQL: business questions, aggregation / window / CTE practice, and a few unrelated SQL practice files.

Database engine: **PostgreSQL 18** (managed in pgAdmin 4).

---

## Contents

- [Project goals](#project-goals)
- [Architecture](#architecture)
- [Source layer (`src`)](#source-layer-src)
- [Warehouse layer (`dw`)](#warehouse-layer-dw)
- [Star / snowflake-style model](#star--snowflake-style-model)
- [Load process](#load-process)
- [Analytical queries](#analytical-queries)
- [Repository structure](#repository-structure)
- [How to rebuild](#how-to-rebuild)
- [Known issues and gaps](#known-issues-and-gaps)

---

## Project goals

1. Consolidate six disaster-type source tables (drought, earthquake, flood, wildfire, volcano eruption, tropical cyclone) into a single, queryable model.
2. Keep disaster-specific attributes in their own subtype tables, so the common fact table stays generic.
3. Answer business questions such as event counts by type and country, yearly trends, population affected, deaths from floods, and severity rankings.

---

## Architecture

The database uses four schemas:

| Schema   | Purpose                                              | Status in repo                         |
|----------|------------------------------------------------------|----------------------------------------|
| `src`    | Raw source tables, one per disaster type (6 tables)  | DDL in repo                            |
| `stg`    | Staging area                                         | Created in pgAdmin, no scripts in repo |
| `dw`     | Warehouse: dimensions, fact and subtype tables (12)  | DDL and load scripts in repo           |
| `public` | Default schema (also holds an unrelated `employee` table used in practice queries) | Not used by the warehouse |

Flow:

```
 CSV / import  ──►  src.*  (6 raw tables)
                      │
                      │  UNION ALL + JOIN to dimensions + GROUP BY
                      ▼
              dw.fact_disaster_event  ◄──  dw.dim_event_type
                      │                ◄──  dw.dim_location
                      │                ◄──  dw.dim_alert
                      │                ◄──  dw.dim_source
                      │                ◄──  dw.dim_date  (start & end date)
                      │
                      │  disaster_event_id
                      ▼
      dw.dim_drought, dim_earthquake, dim_flood,
      dim_wild_fire, dim_volcano, dim_tropical_cyclone
      (subtype dimensions, 1:1 with the fact table)
```

---

## Source layer (`src`)

Each source table holds one disaster type. Columns common to most tables:

| Column                | Meaning                                                |
|-----------------------|--------------------------------------------------------|
| `disaster_event_id`   | Event identifier (business key shared across tables)  |
| `event_type`          | Disaster type code (e.g. `FL` for flood)              |
| `country_location`    | Country / location name                                |
| `iso3`                | ISO 3166 alpha-3 country code                          |
| `alert_level`, `alert_score`, `episode_alert_level`, `episode_alert_score` | Alert classification |
| `source_system`       | Originating system (e.g. GDACS-style sources)          |
| `from_date`, `to_date`| Event start and end dates                              |
| `severity`            | Event severity measure                                 |

Disaster-specific columns:

| Source table       | Extra columns                                                                                  |
|--------------------|------------------------------------------------------------------------------------------------|
| `src.drought`      | `duration_days`, `drought_type`, `effected_area_km2`, `impact_level`, `gdacs_id`               |
| `src.earthquake`   | `earthquake_magnitude`, `depth_km`, `population_effected`, `impact_category`                   |
| `src.flood`        | `death`, `displaced`, `gdacs_id`                                                               |
| `src.wild_fire`    | `gdacs_id`, `population_effected`, `duration_days`, `burned_area`                              |
| `src.volcano_eruption` | `volcano_name`, `volcano_number`, `volcano_explosivity_index`, `population_exposure_index`, `population_effected` |
| `src.tropical_cyclone` | `cyclone_name`, `country_location`, `exposed_population`, `maximum_wind_speed`, `category`, `vulnerability` |

Source tables have no primary keys or constraints. Data types are mixed (`text` for many numeric-looking fields such as `duration_days` in drought), so the load step casts where needed.

---

## Warehouse layer (`dw`)

### Core dimensions

| Table               | Grain / key                                   | Columns                                                                                  |
|---------------------|-----------------------------------------------|------------------------------------------------------------------------------------------|
| `dw.dim_date`       | One row per calendar date (`date_id` SERIAL)  | `full_date` (unique), `year`, `quarter`, `month`, `month_name`, `day`, `day_of_week`, `day_name` |
| `dw.dim_location`   | One row per country/ISO3 pair (`location_id`) | `country_location_name`, `iso3`; unique on (name, iso3)                                  |
| `dw.dim_event_type` | One row per event type (`event_type_id`)      | `event_type` (unique)                                                                    |
| `dw.dim_alert`      | One row per alert combination (`alert_id`)    | `alert_level`, `alert_score`, `episode_alert_level`, `episode_alert_score`, `impact_level`, `impact_category` |
| `dw.dim_source`     | One row per source system (`source_id`)       | `source_system` (unique)                                                                 |

### Fact table

`dw.fact_disaster_event` — one row per `disaster_event_id` (unique constraint).

| Column                       | Type      | Notes                                                 |
|------------------------------|-----------|-------------------------------------------------------|
| `fact_id`                    | BIGSERIAL | Surrogate primary key                                 |
| `disaster_event_id`          | TEXT      | Business key, unique                                  |
| `event_type_id`              | INT, FK   | → `dim_event_type`                                    |
| `location_id`                | INT, FK   | → `dim_location`                                      |
| `alert_id`                   | INT, FK   | → `dim_alert`                                         |
| `source_id`                  | INT, FK   | → `dim_source`                                        |
| `start_date_id`              | INT, FK   | → `dim_date` (role-played)                            |
| `end_date_id`                | INT, FK   | → `dim_date` (role-played)                            |
| `severity`                   | DECIMAL   | Measure (max across source rows)                      |
| `duration_days`              | INT       | Measure (max across source rows)                      |
| `population_effected`        | INT       | Measure (sum)                                         |
| `death`                      | INT       | Measure (sum)                                         |
| `displaced`                  | INT       | Measure (sum)                                         |
| `effected_area_km2`          | INT       | Measure (sum)                                         |

### Subtype dimensions

One table per disaster type, keyed by `disaster_event_id` and referencing `fact_disaster_event`. They hold attributes that only apply to one disaster type.

| Table                    | Attributes                                                              |
|--------------------------|-------------------------------------------------------------------------|
| `dw.dim_drought`         | `drought_type`                                                          |
| `dw.dim_earthquake`      | `earthquake_magnitude`, `depth_km`                                      |
| `dw.dim_flood`           | `gdacs_id`                                                              |
| `dw.dim_wild_fire`       | `burned_area`                                                           |
| `dw.dim_volcano`         | `volcano_name`, `volcano_number`, `volcano_explosivity_index`, `population_exposure_index` |
| `dw.dim_tropical_cyclone`| `cyclone_name`, `maximum_wind_speed`, `category`, `vulnerability`       |

---

## Star / snowflake-style model

The model is a **star schema** at the centre (fact plus five shared dimensions) with **subtype dimensions** hanging off the fact on `disaster_event_id`. Two design choices are worth knowing:

- **Role-playing date dimension.** `dim_date` is joined twice, as `start_date_id` and `end_date_id`.
- **Supertype / subtype split.** Common measures stay in the fact table. Disaster-specific attributes go into one table per type, so the fact table does not need many nullable columns.

The ERD (`New ERD Disaster Project.png`) shows this design. Some details differ from the DDL; see [Known issues](#known-issues-and-gaps).

---

## Load process

Run the scripts in this order:

1. **`Disaster Source Tables Creation Queries.sql`** — creates the six `src.*` tables.
2. **Load source data into `src.*`** — done through pgAdmin import (no script in the repo).
3. **Load shared dimensions** — `dim_date`, `dim_location`, `dim_event_type`, `dim_alert`, `dim_source` (no script in the repo; see gaps).
4. **`Disaster Dimensions-Fact Tables Creation Queries.sql`** — creates all 12 `dw` tables.
5. **`Disaster Fact table Insertion.sql`** — builds the fact table:
   - `UNION ALL` of the six source tables into one stream, with NULLs for measures a type does not have.
   - Joins to all five shared dimensions.
   - `GROUP BY disaster_event_id` plus dimension keys, using `MAX` for severity and duration and `SUM` for population, deaths, displaced, and area.
   - `ON CONFLICT (disaster_event_id) DO NOTHING` makes the load safe to rerun.
6. **`Disaster specific dimensions insertion.sql`** — fills the subtype dimensions. Each insert joins back to the fact table, so only events present in the fact table are loaded.

---

## Analytical queries

### Business questions (`Disaster Business Questions.sql`)

- Disasters by event type
- Disasters by country, and top 10 disaster-prone countries
- Disasters by year (uses `end_date_id`)
- Total deaths from floods

### Concept practice (`SQL concepts quries/`)

| File                                  | Topics                                                              |
|---------------------------------------|---------------------------------------------------------------------|
| `Basic filtering and selection.sql`   | `WHERE`, `LIKE`, `IS NULL`, `BETWEEN`                               |
| `Aggregation Questions.sql`           | `GROUP BY`, `HAVING`, basic and intermediate aggregates, percentage of total with window `SUM() OVER ()` |
| `Case when Questions.sql`             | Conditional categories (duration, population impact) and conditional counts |
| `CTE's Practice.sql`                  | Single and chained CTEs, CTE used as a scalar subquery              |
| `Join types Right Left Outer.sql`     | `LEFT JOIN` to find countries with zero disasters and alert gaps    |
| `window functions disaster data.sql`  | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, running totals   |

### Other practice files (root)

- `Window Functions using employee table.sql` — second highest salary and duplicate-department queries on a sample `employee` table, not part of the disaster warehouse.

---

## Repository structure

```
Data Warehouse/
├── README.md                                       ← this file
├── Disaster Source Tables Creation Queries.sql     ← src.* DDL
├── Disaster Dimensions-Fact Tables Creation Queries.sql  ← dw.* DDL
├── Disaster Fact table Insertion.sql               ← fact load
├── Disaster specific dimensions insertion.sql      ← subtype dimension load
├── Disaster Business Questions.sql                 ← business queries
├── Window Functions using employee table.sql       ← practice (unrelated table)
├── SQL concepts quries/                            ← practice queries by topic
├── data ware house disasters event.pgerd           ← pgAdmin ERD source file
├── ERD chen notation(.pdf)                         ← Chen-notation ERD
├── ERD cross foot notation(.txt)                   ← crow's-foot ERD notes
├── ERD disaster Events .png                        ← ERD image
├── New ERD Disaster Project.png                    ← current ERD image
└── pg admin *.png, Untitled.png                    ← pgAdmin screenshots and notes
```

---

## How to rebuild

Requirements: PostgreSQL (developed against PostgreSQL 18 through pgAdmin 4). The scripts use only standard SQL features (`SERIAL`, `UNION ALL`, window functions, `ON CONFLICT`), so other recent versions should work, but this has not been tested elsewhere.

```sql
-- 1. Create the schemas
CREATE SCHEMA IF NOT EXISTS src;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;

-- 2. Run the scripts in load order
--    a. Disaster Source Tables Creation Queries.sql
--    b. Import the six source datasets into src.* (CSV import in pgAdmin)
--    c. Populate dw.dim_date, dw.dim_location, dw.dim_event_type,
--       dw.dim_alert, dw.dim_source  (not included in the repo yet)
--    d. Disaster Dimensions-Fact Tables Creation Queries.sql
--    e. Disaster Fact table Insertion.sql
--    f. Disaster specific dimensions insertion.sql
```

---

## Known issues and gaps

These came from reviewing the SQL files against the ERD and against each other.

1. **Shared dimension loaders are missing.** Nothing in the repo populates `dim_date`, `dim_location`, `dim_event_type`, `dim_alert`, or `dim_source`, and the source CSV import is manual. The fact load depends on these tables, so the warehouse cannot be rebuilt from the scripts alone.
2. **Inner joins can drop events silently.** The fact load uses `JOIN` on `iso3` and on the four alert columns. In SQL, `NULL = NULL` is not true, so events with a NULL `iso3` or a NULL episode score are excluded without warning. Check row counts against `src.*` after each load.
3. **`ON CONFLICT DO NOTHING` hides duplicates.** If one event has conflicting rows (for example two different alert levels), only one row is kept and the other is discarded without a message. Consider logging these cases.
4. **Subtype loads may fail on duplicates.** The subtype `INSERT ... SELECT DISTINCT` statements assume one row per `disaster_event_id` in each subtype. If a source table repeats an event with different values, the primary key on the subtype table will reject the insert.
5. **ERD and DDL disagree.** The ERD places `effected_area_km2` in `dim_drought`. The DDL and fact load put it in `fact_disaster_event`. The DDL is the authority here.
6. **Inconsistent date role.** The "Disasters by year" business query uses `end_date_id`, while the concept queries use `start_date_id`. Pick one and document it.
7. **Event type codes are assumed.** The flood query filters on `event_type = 'FL'`, which matches GDACS-style codes. Confirm the codes in `dw.dim_event_type`.
8. **Unrelated files in the project.** The employee-table practice file in the root is not connected to the disaster model.
9. **Small query issues in practice files.**
   - The second-highest-salary query in `Window Functions using employee table.sql` uses `DENSE_RANK() OVER (ORDER BY salary)`, which ranks ascending. That returns the second-lowest salary. Use `DESC`.
   - `Basic filtering and selection.sql` says "High" alert level but filters on `'Red'`.
   - "Average population affected per disaster type" in `Case when` and `Aggregation` files actually computes a `SUM`.
10. **No automated tests.** Row counts, referential-integrity checks, and totals reconciliation against the source tables are not in the repo.

---

## Author

Waqar Haider Saddique

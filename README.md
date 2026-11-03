# Global Disaster Events (2000–2025) – SQL Data Warehouse

A PostgreSQL data warehouse of global disaster events from 2000 to 2025.

Six disaster types (drought, earthquake, flood, wildfire, volcano eruption, tropical cyclone) are stored in separate source tables. They are combined into one **fact table**, which connects to **dimension tables**.

This repo also holds my SQL practice files (aggregation, joins, window functions, CTEs, CASE WHEN, filtering).

## Structure

- **`src`** – 6 raw source tables, one per disaster type
- **`dw`** – 12 warehouse tables:
  - 1 fact table: `fact_disaster_event`
  - 5 dimensions: `dim_date`, `dim_location`, `dim_event_type`, `dim_alert`, `dim_source`
  - 6 special dimension tables, one per disaster type, for details only that type has: `dim_drought`, `dim_earthquake`, `dim_flood`, `dim_wild_fire`, `dim_volcano`, `dim_tropical_cyclone`

## Files and load order

| # | File | What it does |
|---|------|--------------|
| 1 | `Disaster Source Tables Creation Queries.sql` | Creates the 6 `src` tables |
| 2 | *(CSV import in pgAdmin)* | Loads the data into the `src` tables |
| 3 | `Disaster Dimensions-Fact Tables Creation Queries.sql` | Creates the 5 core dimensions and the fact table |
| 4 | `Special Dimension Creation.sql` | Creates the 6 special dimension tables |
| 5 | `Disaster Fact table Insertion.sql` | Fills the fact table |
| 6 | `Disaster specific dimensions insertion.sql` | Fills the special dimension tables |
| – | `Disaster Business Questions.sql` | Business queries (counts by type, country, year; flood deaths) |

Other files:

- `New ERD Disaster Project.png` – the data model diagram
- `ERD *`, `*.pgerd`, `pg admin *.png`, `Untitled.png` – ERD and pgAdmin screenshots

## How the fact table is built

The fact table is filled from the 6 source tables:

1. `UNION ALL` stacks the 6 source tables into one list.
2. The list is joined to the dimension tables to get their keys.
3. `GROUP BY` the event gives one row per event.
4. `ON CONFLICT DO NOTHING` skips events that are already loaded, so the script can be run again safely.

## Practice files

These are my practice queries, stored in `SQL concepts quries/`:

| File | Topics |
|------|--------|
| `Basic filtering and selection.sql` | `WHERE`, `LIKE`, `BETWEEN`, `IS NULL` |
| `Aggregation Questions.sql` | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`, percent of total with `SUM() OVER ()` |
| `Case when Questions.sql` | `CASE WHEN` categories and conditional counts |
| `CTE's Practice.sql` | `WITH` queries, single and chained CTEs |
| `Join types Right Left Outer.sql` | `INNER`, `LEFT`, and `RIGHT` joins, finding missing rows |
| `window functions disaster data.sql` | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `SUM() OVER` |

Root practice file:

- `Window Functions using employee table.sql` – second-highest salary and duplicate-department queries on an `employee` table (not part of the disaster warehouse)

## Known gaps
- The CSV import into the source tables is done manually in pgAdmin.

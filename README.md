# Global Disaster Events (2000–2025) – SQL Data Warehouse

A PostgreSQL data warehouse of global disaster events from 2000 to 2025.

Six disaster types (drought, earthquake, flood, wildfire, volcano eruption, tropical cyclone) are stored in separate source tables. They are combined into one **fact table**, which connects to **dimension tables**.

## Structure

- **`src`** – 6 raw source tables, one per disaster type
- **`dw`** – 12 warehouse tables:
  - 1 fact table: `fact_disaster_event`
  - 5 dimensions: `dim_date`, `dim_location`, `dim_event_type`, `dim_alert`, `dim_source`
  - 6 subtype tables: one per disaster type, for details only that type has (e.g. `dim_flood`)

## How it works

1. Create the source tables (`Disaster Source Tables Creation Queries.sql`) and import the data.
2. Create the warehouse tables (`Disaster Dimensions-Fact Tables Creation Queries.sql`).
3. Load the fact table (`Disaster Fact table Insertion.sql`). It combines the 6 source tables with `UNION ALL`, joins them to the dimensions, and groups by event.
4. Load the subtype tables (`Disaster specific dimensions insertion.sql`).

## Files

- `Disaster *.sql` – table creation and data loading scripts
- `Disaster Business Questions.sql` – business queries (counts by type, country, year; flood deaths)
- `SQL concepts quries/` – practice queries (filtering, aggregation, CASE, CTE, joins, window functions)
- `New ERD Disaster Project.png` – the data model diagram

## Known gaps

- The scripts for loading the 5 dimension tables are not in this repo.
- The CSV import into the source tables is done manually in pgAdmin.

## Interview quick answers

- **What is a fact table?** It stores the measurable numbers about each event, such as severity, deaths, and population affected.
- **What is a dimension table?** It stores descriptive details used to filter and group, such as country, date, and event type.
- **What is a star schema?** One fact table in the middle, with dimension tables connected around it. This project follows that design.
- **Why separate subtype tables?** Each disaster type has its own details. Keeping them in separate tables avoids many empty columns in the fact table.
- **Why `UNION ALL`?** It stacks the 6 source tables into one list, so they can be loaded into a single fact table.
- **Why `ON CONFLICT DO NOTHING`?** It skips events that are already loaded, so the load can be run again safely.

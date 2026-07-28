# Border Express — Residential Surcharge Analysis

dbt project modeling the proposed residential delivery surcharge for Border Express, built
on top of raw dimension/fact data loaded into Snowflake (`RESIDENTIAL_SURCHARGE.STAGING`).

## Architecture: medallion (4 stages)

All transformation logic lives in dbt. Power BI is presentation-only — it consumes the gold
layer and defines only the small set of measures needed for the visuals (no business logic
in DAX).

`Staging` is the raw landing zone in Snowflake (`RESIDENTIAL_SURCHARGE.STAGING`) — the 7
source tables loaded as-is, outside of dbt. dbt picks up from there across three layers:
**Bronze** (1:1 cleaned copies of source), **Silver** (joined/enriched), **Gold**
(presentation-ready marts). Each layer writes to its own Snowflake schema
(`RESIDENTIAL_SURCHARGE.BRONZE`/`SILVER`/`GOLD`). Each layer's own folder/`schema.yml` is the
source of truth for what it actually contains — this section only tracks what's built so far.

### Built so far

| Layer      | dbt folder       | Status                                                                                                                                                                                                                                             |
| ---------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Bronze** | `models/bronze/` | Done — 7 models, 1:1 with each raw staging table. Casts types, cleans values (e.g. strips `$`/whitespace from surcharge amounts, parses date strings, zero-pads postcodes), renames to snake_case. No joins, no business logic. All tests passing. |
| **Silver** | `models/silver/` | Done — `int_consignment_surcharge`: one row per consignment, surcharge eligibility and revenue/foregone amounts.                                                                                                                                   |
| **Gold**   | `models/gold/`   | Done — `dim_location` (merged sender/receiver, role-filtered views), `dim_customer`, `dim_date`, `dim_unit_surcharge`, `fct_consignment_surcharge`. This is what Power BI reads.                                                                   |

## Documentation

Model/column descriptions and tests live in each layer's `schema.yml`. Business definitions,
every data quality issue found and the decision taken on it are in
`documentation/data_notes_and_assumptions.md` at the project root.

`sanity_checks/` holds the one-off investigation queries behind each data quality finding -
`snowflake/ddl/` has the staging schema written as SQL.

## Running

```
source .venv/bin/activate
dbt debug   # verify Snowflake connection
dbt build   # run models + tests
dbt docs generate && dbt docs serve   # browse generated documentation
```

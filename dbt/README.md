# Border Express — Residential Surcharge Analysis

dbt project modeling the proposed residential delivery surcharge for Border Express, built
on top of raw dimension/fact data loaded into Snowflake (`RESIDENTIAL_SURCHARGE.STAGING`).

## Architecture: medallion (3 layers)

All transformation logic lives in dbt. Power BI is presentation-only — it consumes the gold
layer and defines only the small set of measures needed for the visuals (no business logic
in DAX).

| Layer | dbt folder | Purpose |
|---|---|---|
| **Bronze** (staging) | `models/staging/` | 1:1 with each raw source table. Casts types, cleans values (e.g. strips `$`/whitespace from surcharge amounts, parses date strings), renames to consistent snake_case. No joins, no business logic. |
| **Silver** (intermediate) | `models/intermediate/` | Joins consignments to their dimensions (receiver location, customer, service type, unit surcharge tier). Derives row-level business flags: `is_residential`, `is_excluded_customer`, `surcharge_tier`, `surcharge_amount`. |
| **Gold** (marts) | `models/marts/` | Aggregated, presentation-ready models that answer the stakeholder questions directly (incremental revenue, foregone revenue, top customers, supporting insight cuts). These are what Power BI connects to. |

## Documentation

Model/column descriptions, tests, and business definitions (e.g. what counts as an
"eligible" vs "excluded" customer, how the surcharge tier is derived) live in each layer's
`schema.yml` and will be expanded into a full documentation pass once the models are built —
see project-level `documentation/` folder for the consolidated writeup.

## Running

```
source .venv/bin/activate
dbt debug   # verify Snowflake connection
dbt build   # run models + tests
dbt docs generate && dbt docs serve   # browse generated documentation
```

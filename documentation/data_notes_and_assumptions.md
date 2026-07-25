# Data Notes, Assumptions & Business Definitions

This is the running record of every non-obvious decision, data quality issue, and business
definition behind the residential surcharge analysis — anything a reviewer might otherwise
have to reverse-engineer from the SQL. It is updated as each layer of the project is built,
not written once upfront.

Technical architecture (layers, tooling, how to run the project) is documented separately in
`dbt/README.md`. This file is about the *data and the business logic*, not the pipeline
mechanics.

## The business ask (source: stakeholder briefing + manager notes)

Border Express is evaluating a new surcharge on deliveries to **residential** addresses,
priced by the number of units in the consignment, to cover extra handling effort:

| Units | Surcharge |
|---|---|
| 0–1 | $5 |
| 2 | $8 |
| 3–5 | $12 |
| >5 | $15 |

Stakeholders want three numbers plus one extra insight of our choosing:
1. Additional annual revenue the surcharge would generate from **eligible** customers.
2. Annual revenue **foregone** on **excluded** customers (i.e. what they'd have generated
   had they not been excluded).
3. The **top 10 eligible customers** affected, and the impact relative to their existing
   overall charges.
4. At least one further visualization that anticipates what stakeholders will want to know
   next.

## Business definitions

- **Consignment** — a single shipment from a sender to a receiver; one row in
  `FactConsignment`. Carries units shipped, charge, and paying customer.
- **Pre-GST Charge** — the freight cost charged to the customer for a consignment,
  excluding GST. Referred to internally as "Connote Revenue." This is the revenue baseline
  the surcharge impact is measured against.
- **Service Type** — Parcel (small, separate cartons) vs Bulk (palletized cartons).
- **Units** — number of cartons/parcels in a consignment. Drives which surcharge tier
  applies via `DimUnitSurcharge`.
- **Eligible customer** — `DimCustomer.ExcludeSurcharge = 0`. In scope for the new
  surcharge.
- **Excluded customer** — `DimCustomer.ExcludeSurcharge = 1`. Explicitly carved out of the
  surcharge by the business (reason not given in the brief — worth asking stakeholders).
- **Residential delivery** — `DimReceiverLocation.ReceiverResidentialAddress = 1`. Based on
  the **receiver** location, not the sender. The surcharge only applies to residential
  *deliveries* — a residential *sender* location is irrelevant to this surcharge.
- **Surcharge eligible row** (working definition, to be applied once silver is built) — a
  consignment where the receiver is residential AND the customer is not excluded. Only these
  rows would generate the "additional revenue" in question 1. Rows that are residential but
  excluded would feed question 2 (revenue foregone) instead.

## Data quality findings and how each was handled

All 7 source tables (`DimCalender`, `DimCustomer`, `DimSenderLocation`,
`DimReceiverLocation`, `DimServiceType`, `DimUnitSurcharge`, `FactConsignment`) were already
loaded as-is into Snowflake (`RESIDENTIAL_SURCHARGE.STAGING`) before this project started.
Nothing in that raw layer was modified — every fix below happens in the dbt bronze layer
(`dbt/models/bronze/`), i.e. at transformation time, not at the source.

1. **`DimUnitSurcharge.Surcharge` arrives as formatted currency text**, e.g. `" $ 5.00 "`,
   not a number. Cleaned via `regexp_replace` to strip everything but digits/decimal point,
   then cast to `NUMBER(10,2)` in `stg_dim_unit_surcharge`. The four tiers in the table
   (`0-1→$5`, `2→$8`, `3-5→$12`, `6-9999→$15`) match the brief exactly, and the top tier's
   explicit `unit_to = 9999` means tier lookups can be a simple `BETWEEN`, no open-ended
   `CASE` needed.

2. **Postcodes lost their leading zero.** `SenderPostcode`/`ReceiverPostcode` are stored as
   `NUMBER` in Snowflake (and were already 3-digit text in the raw CSV before that -
   Excel auto-stripped the leading zero on export). This corrupts any Northern Territory
   postcode (valid range 0800–0999): e.g. `810` should read `0810`. Confirmed 4 receiver
   rows and 2 sender rows affected, all NT.
   **Decision:** zero-pad back to 4 characters (`lpad(postcode::varchar, 4, '0')`) in
   bronze. Low impact on the 3 core stakeholder questions (state comes from the separate
   `ReceiverState`/`SenderState` text column, not derived from postcode), but would have
   shown wrong postcodes in any drill-down/visual otherwise.

3. **One orphan `customer_code`, caused by a case-sensitivity typo, not a missing
   customer.** `FactConsignment` has `customer_code = 'DIA9'` (invoice 73294325, consignment
   21537628, 2022-06-09, $32.37) which doesn't match any row in `DimCustomer` on an exact,
   case-sensitive join. Investigated before assuming: `DimCustomer` does contain a customer
   with code `dia9` (lowercase) mapped to "Hills, Jacobs and ..." — every other customer
   code in that table is uppercase (`BOC59`, `DAL9`, `YAM9`, etc.), confirming this is a
   one-off data entry typo in the dimension table, not a systemic case convention
   difference.
   **Decision:** normalize `customer_code` to uppercase on both sides of the join
   (`upper(trim(...))` in `stg_dim_customer` and `stg_fact_consignment`). This resolves the
   join without altering the raw source table - the fix lives entirely in the
   transformation layer, consistent with the instruction not to change the data we were
   given.

## Open questions worth raising with stakeholders

- Why are some customers excluded from the surcharge in the first place (business reason
  not stated in the brief) - could be relevant framing for question 2's revenue-foregone
  number.
- Whether annualising one month of dummy data by a flat x12 is acceptable, or whether a more
  conservative/seasonally-aware method is expected - the exact annualisation method used
  will be documented here once the gold layer is built.

## Status

Bronze layer (7 models, casts/cleaning only) complete and passing all dbt tests as of this
writing. Silver (joins + business flags) and gold (marts answering the stakeholder
questions) are not yet built - this file will be extended with the exact revenue
calculation/annualisation logic once those layers exist.

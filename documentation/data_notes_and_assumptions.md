# Data Notes, Assumptions & Business Definitions

This is the running record of every non-obvious decision, data quality issue, and business
definition behind the residential surcharge analysis — anything a reviewer might otherwise
have to reverse-engineer from the SQL. It is updated as each layer of the project is built,
not written once upfront.

Technical architecture (layers, tooling, how to run the project) is documented separately in
`dbt/README.md`. This file is about the _data and the business logic_, not the pipeline
mechanics.

## The business ask (source: stakeholder briefing + manager notes)

Border Express is evaluating a new surcharge on deliveries to **residential** addresses,
priced by the number of units in the consignment, to cover extra handling effort:

| Units | Surcharge |
| ----- | --------- |
| 0–1   | $5        |
| 2     | $8        |
| 3–5   | $12       |
| >5    | $15       |

Stakeholders want three numbers plus one extra insight of our choosing:

1. Additional annual revenue the surcharge would generate from **eligible** customers.
2. Annual revenue **foregone** on **excluded** customers (i.e. what they'd have generated
   had they not been excluded).
3. The **top 10 eligible customers** affected, and the impact relative to their existing
   overall charges.
4. At least one further visualization that anticipates what stakeholders will want to know
   next.

The source data is a single month (June 2022), but questions 1 and 2 ask for annual figures.
Scaling a month up by x12 to answer that would mean presenting a fabricated number as if it
were real revenue - not something we should be doing to the data on the stakeholders' behalf.
**Decision:** gold presents the actual June 2022 revenue/foregone amounts, not an annualized
estimate. If stakeholders want an annual projection, that's a call for them to make once
they've seen the monthly numbers and know what they're built on - not something baked
silently into the model.

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
  _deliveries_ — a residential _sender_ location is irrelevant to this surcharge.
- **Surcharge eligible row** — a consignment where the receiver is residential AND the
  customer is not excluded AND `total_units` matches a real tier in `DimUnitSurcharge`.
  Implemented in `int_consignment_surcharge` (silver). Only these rows generate the
  "additional revenue" in question 1. Rows that are residential but excluded feed question 2
  (revenue foregone) instead.

## Data quality findings and how each was handled

All 7 source tables (`DimCalender`, `DimCustomer`, `DimSenderLocation`,
`DimReceiverLocation`, `DimServiceType`, `DimUnitSurcharge`, `FactConsignment`) were already
loaded as-is into Snowflake (`RESIDENTIAL_SURCHARGE.STAGING`) before this project started.

1. **`DimUnitSurcharge.Surcharge` arrives as formatted currency text**, e.g. `" $ 5.00 "`,
   not a number. Cleaned via `regexp_replace` to strip everything but digits/decimal point,
   then cast to `NUMBER(10,2)` in `stg_dim_unit_surcharge`. The four tiers in the table
   (`0-1→$5`, `2→$8`, `3-5→$12`, `6-9999→$15`) match the brief exactly, and the top tier's
   explicit `unit_to = 9999` means tier lookups can be a simple `BETWEEN`, no open-ended
   `CASE` needed.

2. **Postcodes lost their leading zero.** `SenderPostcode`/`ReceiverPostcode` are stored as
   `NUMBER` in Snowflake. This corrupts any Northern Territory
   postcode (valid range 0800–0999): e.g. `810` should read `0810`. Confirmed 4 receiver
   rows and 2 sender rows affected, all NT.
   **Decision:** zero-pad back to 4 characters (`lpad(postcode::varchar, 4, '0')`) in
   bronze.

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

4. **9 rows have `TotalUnits = 2.5`.** `round(2.5) = 3`, so these land in the 3-5 tier
   (\$12) instead of the 2-unit tier (\$8) - a \$4/consignment difference.
   **Decision:** round to nearest whole unit in bronze. Was already happening implicitly via
   the `::integer` cast (rounds, not truncates) - made it explicit with `round()`.

5. **2 consignments have `total_units = -1`, which doesn't match any `DimUnitSurcharge`
   tier.** Found while building `int_consignment_surcharge` (silver) - the tier lookup came
   back null for these 2 rows. Both also have a negative `pre_gst_charge` and a consignment number in a different format than usual. 37 rows total have a negative charge, but only these 2 also have
   negative units, so most credits/adjustments carry a normal positive unit count and aren't
   affected. These 2 read as credit/reversal entries against an earlier consignment, not real
   deliveries.
   **Decision:** in `int_consignment_surcharge`, treat these 2 rows as not eligible with
   `surcharge_amount = 0` rather than null - the row stays,
   it just contributes nothing to either the revenue or foregone numbers, since there's no
   genuine unit count to price a surcharge tier against.
   In gold they point at an unknown member row in `dim_unit_surcharge`
   (`unit_surcharge_id = -1`, labelled "Unknown / no tier") instead of carrying a null FK.
   A null FK is skipped by dbt's `relationships` test, so the unresolved join stays green, and
   it drops the rows out of any Power BI visual sliced by unit tier - the tier breakdown then
   doesn't reconcile to the fact table total. The unknown member keeps them countable and lets
   `unit_surcharge_sk` carry a `not_null` test.

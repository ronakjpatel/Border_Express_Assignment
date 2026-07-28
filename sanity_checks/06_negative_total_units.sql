-- Building int_consignment_surcharge, the tier lookup against DimUnitSurcharge came back null
-- for 2 rows - checking what's going on with those before deciding how to handle them.

-- Step 1: find the rows that don't match any unit_surcharge tier
select
    f.invoice_id,
    f.consignment_number,
    f.total_units,
    f.pre_gst_charge
from RESIDENTIAL_SURCHARGE.staging.FactConsignment f
left join RESIDENTIAL_SURCHARGE.staging.DimUnitSurcharge u
    on f.totalunits between u.unit_from and u.unit_to
where u.id is null;

-- Step 2: how common is negative pre_gst_charge 
select
    count(*) as negative_charge_rows
from RESIDENTIAL_SURCHARGE.staging.FactConsignment
where pregstcharge < 0;

-- Both rows have total_units = -1 and a negative pre_gst_charge, with
-- consignment numbers in a different format than usual.
-- 37 rows total have a negative charge, but only these 2 also have negative units - so most
-- credits/adjustments carry a normal positive unit count and flow through the tier lookup
-- fine. These 2 read as credit/reversal entries against an earlier consignment, not real
-- deliveries - there's no genuine unit count to price a surcharge tier against.
-- Decision: in int_consignment_surcharge, treat these as not eligible and surcharge_amount is 0 rather than null, so no contribution nothing to either the revenue or foregone numbers.

-- While looking at total_units, checking whether it's always a whole number - it drives

select
    totalunits,
    count(*) as row_count
from RESIDENTIAL_SURCHARGE.staging.FactConsignment
where totalunits != round(totalunits)
group by totalunits;

-- Exactly one fractional value shows up: 2.5, on 9 rows. Matters because it changes which
-- tier those rows land in - round(2.5) = 3 puts them in the 3-5 tier ($12) instead of the
-- 2-unit tier ($8), made it explicit with round() instead so
-- it's a deliberate call, not a side effect of the cast type.
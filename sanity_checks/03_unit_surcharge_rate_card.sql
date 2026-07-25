-- Want to see what the raw surcharge rate card actually looks like, and check it matches the
-- tiers in the stakeholder brief (0-1 -> $5, 2 -> $8, 3-5 -> $12, >5 -> $15).
select
    id,
    unit_from,
    unit_to,
    surcharge
from RESIDENTIAL_SURCHARGE.staging.DimUnitSurcharge
order by unit_from;

-- Surcharge arrives as formatted currency text (e.g. " $ 5.00 "), not a number - needs


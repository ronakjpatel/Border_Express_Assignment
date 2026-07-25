-- The manager notes say charges are based on Sales Post Date, so checking it's fully
-- populated and parses cleanly before I use it as the date basis for the analysis.
select
    count(*) as total_rows,
    count(salespostdate) as non_null_salespostdate,
    count(try_to_date(salespostdate, 'MM/DD/YYYY HH24:MI:SS')) as parseable_salespostdate
from RESIDENTIAL_SURCHARGE.staging.FactConsignment;

-- All three counts come back equal at 1,999 - SalesPostDate is fully populated and every
-- value parses against MM/DD/YYYY HH24:MI:SS (e.g. "6/9/2022 0:00:00"), no format outliers.
-- Using it as the date basis for all revenue/annualisation logic downstream, per the brief.

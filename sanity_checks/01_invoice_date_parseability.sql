-- Checking InvoiceDate is fully populated and parses cleanly against the format I'm
-- expecting, before I rely on it anywhere.
select
    count(*) as total_rows,
    count(invoicedate) as non_null_invoicedate,
    count(try_to_date(invoicedate, 'MM/DD/YYYY HH24:MI:SS')) as parseable_invoicedate
from RESIDENTIAL_SURCHARGE.staging.FactConsignment;

-- All three counts come back equal at 1,999 - InvoiceDate is fully populated and every value
-- parses against MM/DD/YYYY HH24:MI:SS (e.g. "6/9/2022 0:00:00"), no format outliers.

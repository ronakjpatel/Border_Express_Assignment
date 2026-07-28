-- Checking row counts on the raw staging tables before I build anything on top of them. Want
-- a number to point to if anyone asks whether all the data actually loaded.
select 'DimCalender' as source_table, count(*) as row_count from RESIDENTIAL_SURCHARGE.staging.DimCalender
union all
select 'DimCustomer', count(*) from RESIDENTIAL_SURCHARGE.staging.DimCustomer
union all
select 'DimSenderLocation', count(*) from RESIDENTIAL_SURCHARGE.staging.DimSenderLocation
union all
select 'DimReceiverLocation', count(*) from RESIDENTIAL_SURCHARGE.staging.DimReceiverLocation
union all
select 'DimServiceType', count(*) from RESIDENTIAL_SURCHARGE.staging.DimServiceType
union all
select 'DimUnitSurcharge', count(*) from RESIDENTIAL_SURCHARGE.staging.DimUnitSurcharge
union all
select 'FactConsignment', count(*) from RESIDENTIAL_SURCHARGE.staging.FactConsignment
order by source_table;

-- FactConsignment came in at 1,999 rows (one month of sample data, June 2022), all dimension
-- tables populated. No empty tables, nothing obviously truncated - good to build on.

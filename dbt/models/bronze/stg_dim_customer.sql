-- Bronze layer: 1:1 with DimCustomer, explicit types. is_excluded_from_surcharge: true = ExcludeSurcharge=1.
-- customer_code is upper-cased: one row in this table has customer code "dia9" (lowercase),while every other row here and every reference in FactConsignment is uppercase ("DIA9"). Normalizing case on both sides of the join (see stg_fact_consignment) fixes this single
-- data entry typo without altering the raw source data itself.
select
    upper(trim(payingaccountcodeid::varchar)) as customer_code,
    customernamerg::varchar                    as customer_name,
    case
        when excludesurcharge::integer = 1 then true
        else false
    end                                        as is_excluded_from_surcharge
from {{ source('staging', 'DimCustomer') }}

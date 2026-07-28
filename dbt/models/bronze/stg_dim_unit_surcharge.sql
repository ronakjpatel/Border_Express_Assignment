-- Bronze layer: 1:1 with DimUnitSurcharge, explicit types. Surcharge arrives as text like
-- " $ 5.00 " - strip everything except digits/decimal point and cast to a number.
select
    id::integer                                                  as unit_surcharge_id,
    unit_from::integer                                           as unit_from,
    unit_to::integer                                              as unit_to,
    regexp_replace(surcharge, '[^0-9.]', '')::number(10, 2)      as surcharge_amount 
from {{ source('staging', 'DimUnitSurcharge') }}

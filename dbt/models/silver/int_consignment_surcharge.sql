-- Silver layer: one row per consignment,
-- 2 rows have total_units = -1 (paired with a negative pre_gst_charge too)
-- Coalescing surcharge_amount to 0 and treating them as not eligible rather than leaving them null, since there's no real unit count to price a surcharge tier against.
with fact as (
    select * from {{ ref('stg_fact_consignment') }}
),

customer as (
    select * from {{ ref('stg_dim_customer') }}
),

receiver_location as (
    select * from {{ ref('stg_dim_receiver_location') }}
),

unit_surcharge as (
    select * from {{ ref('stg_dim_unit_surcharge') }}
)

select
    fact.invoice_id,
    fact.consignment_number,
    fact.sales_post_date,
    fact.invoice_date,
    fact.customer_code,
    fact.receiver_location_id,
    fact.sender_location_id,
    fact.service_type_id,
    fact.pre_gst_charge,
    fact.total_units,
    unit_surcharge.unit_surcharge_id,
    coalesce(unit_surcharge.surcharge_amount, 0) as surcharge_amount,
    case
        when receiver_location.is_receiver_residential
            and not customer.is_excluded_from_surcharge
            and unit_surcharge.surcharge_amount is not null
            then true
        else false
    end as is_surcharge_eligible,
    case
        when receiver_location.is_receiver_residential
            and not customer.is_excluded_from_surcharge
            and unit_surcharge.surcharge_amount is not null
            then unit_surcharge.surcharge_amount
        else 0
    end as surcharge_revenue_amount,
    case
        when receiver_location.is_receiver_residential
            and customer.is_excluded_from_surcharge
            and unit_surcharge.surcharge_amount is not null
            then unit_surcharge.surcharge_amount
        else 0
    end as surcharge_foregone_amount
from fact
left join customer
    on fact.customer_code = customer.customer_code
left join receiver_location
    on fact.receiver_location_id = receiver_location.receiver_location_id
left join unit_surcharge
    on fact.total_units between unit_surcharge.unit_from and unit_surcharge.unit_to

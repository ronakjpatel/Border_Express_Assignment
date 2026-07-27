-- One row per consignment (same grain lik silver - deliberately not pre-aggregated, so PowerBI can slice however the presentation needs). 
-- Resolves the surrogate-key FKs usig the same surrogate_key() macro as the dims, so the match 
with consignment as (
    select * from {{ ref('int_consignment_surcharge') }}
),

service_type as (
    select * from {{ ref('stg_dim_service_type') }}
)

select
    consignment.invoice_id,
    consignment.consignment_number,
    consignment.sales_post_date,
    to_number(to_char(consignment.sales_post_date, 'YYYYMMDD'))          as date_sk,
    {{ surrogate_key(['consignment.customer_code']) }}                   as customer_sk,
    {{ surrogate_key(["'sender'", 'consignment.sender_location_id']) }}   as sender_location_sk,
    {{ surrogate_key(["'receiver'", 'consignment.receiver_location_id']) }} as receiver_location_sk,
    {{ surrogate_key(['consignment.unit_surcharge_id']) }}       as unit_surcharge_sk,
    service_type.service_type_description,
    consignment.pre_gst_charge,
    consignment.total_units,
    consignment.surcharge_amount,
    consignment.is_surcharge_eligible,
    consignment.surcharge_revenue_amount,
    consignment.surcharge_foregone_amount
from consignment
left join service_type
    on consignment.service_type_id = service_type.service_type_id

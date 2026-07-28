{{ config(materialized='view') }}

-- Role-filtered view over dim_location, for a clean single-relationship Power BI import.
select
    location_sk as receiver_location_sk,
    location_id as receiver_location_id,
    suburb as receiver_suburb,
    state as receiver_state,
    postcode as receiver_postcode,
    is_residential as is_receiver_residential
from {{ ref('dim_location') }}
where location_role = 'receiver'

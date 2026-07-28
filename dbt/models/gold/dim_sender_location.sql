{{ config(materialized='view') }}

-- Role-filtered view over dim_location, for a clean single-relationship Power BI import.
select
    location_sk as sender_location_sk,
    location_id as sender_location_id,
    suburb as sender_suburb,
    state as sender_state,
    postcode as sender_postcode,
    is_residential as is_sender_residential
from {{ ref('dim_location') }}
where location_role = 'sender'

-- Role-playing dimension: sender and receiver locations are the same shape, so one physical table 
with sender as (
    select
        'sender' as location_role,
        sender_location_id as location_id,
        sender_suburb as suburb,
        sender_state as state,
        sender_postcode as postcode,
        is_sender_residential as is_residential
    from {{ ref('stg_dim_sender_location') }}
),

receiver as (
    select
        'receiver' as location_role,
        receiver_location_id as location_id,
        receiver_suburb as suburb,
        receiver_state as state,
        receiver_postcode as postcode,
        is_receiver_residential as is_residential
    from {{ ref('stg_dim_receiver_location') }}
),

combined as (
    select * from sender
    union all
    select * from receiver
)

select
    {{ surrogate_key(['location_role', 'location_id']) }} as location_sk,
    location_role,
    location_id,
    suburb,
    state,
    postcode,
    is_residential
from combined

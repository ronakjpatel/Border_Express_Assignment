-- Bronze layer: 1:1 with DimReceiverLocation, explicit types. is_receiver_residential drives surcharge eligibility.
-- receiver_postcode is zero-padded to 4 chars: lpad reconstructs the correct display value.
select
    receiverlocationid::integer                              as receiver_location_id,
    receiversuburb::varchar                                  as receiver_suburb,
    receiverstate::varchar                                   as receiver_state,
    lpad(receiverpostcode::varchar, 4, '0')::varchar(4)       as receiver_postcode,
    case
        when receiverresidentialaddress::integer = 1 then true
        else false
    end                                                       as is_receiver_residential
from {{ source('staging', 'DimReceiverLocation') }}

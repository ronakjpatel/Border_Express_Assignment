-- Bronze layer: 1:1 with DimSenderLocation, explicit types. is_sender_residential: true = SenderResidentialAddress=1.
-- sender_postcode is zero-padded to 4 chars: lpad reconstructs the correct display value.
select
    senderlocationid::integer                              as sender_location_id,
    sendersuburb::varchar                                  as sender_suburb,
    senderstate::varchar                                   as sender_state,
    lpad(senderpostcode::varchar, 4, '0')::varchar(4)       as sender_postcode,
    case
        when senderresidentialaddress::integer = 1 then true
        else false
    end                                                     as is_sender_residential
from {{ source('staging', 'DimSenderLocation') }}

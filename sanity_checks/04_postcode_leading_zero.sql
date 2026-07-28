-- Postcodes are stored as NUMBER in Snowflake. Any Northern Territory postcode(valid range
-- 0800-0999) wouldve silently lost its leading zero on the way in - checking both sender
-- and receiver location tables for this before I trust postcod data anywhere downstream
-- (e.g a drill-down visual).
select
    'receiver' as location_type,
    receiverlocationid as location_id,
    receiverpostcode as postcode_as_stored,
    receiverstate as state
from RESIDENTIAL_SURCHARGE.staging.DimReceiverLocation
where receiverpostcode between 800 and 999

union all

select
    'sender' as location_type,
    senderlocationid as location_id,
    senderpostcode as postcode_as_stored,
    senderstate as state
from RESIDENTIAL_SURCHARGE.staging.DimSenderLocation
where senderpostcode between 800 and 999

order by location_type, location_id;

-- 4 receiver rows and 2 sender rows affected, all in NT. Fixing with
-- lpad(postcode::varchar, 4, '0') in bronze

-- Bronze layer: 1:1 with DimServiceType, renamed to snake_case with explicit types.
select
    servicetypeid::integer          as service_type_id,
    description::varchar            as service_type_description
from {{ source('staging', 'DimServiceType') }}

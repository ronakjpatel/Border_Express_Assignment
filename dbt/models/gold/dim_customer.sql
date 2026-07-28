select
    {{ surrogate_key(['customer_code']) }} as customer_sk,
    customer_code,
    customer_name,
    is_excluded_from_surcharge
from {{ ref('stg_dim_customer') }}

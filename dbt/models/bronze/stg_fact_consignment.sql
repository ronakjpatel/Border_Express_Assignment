-- Bronze layer: 1:1 with FactConsignment
-- customer_code is upper-cased to match the normalization in stg_dim_customer (fixes a single "dia9" vs "DIA9" case-mismatch typo in the source dimension table).
select
    invoice_id::integer                                             as invoice_id,
    consignmentnumber::varchar                                      as consignment_number,
    to_date(invoicedate, 'MM/DD/YYYY HH24:MI:SS')::date              as invoice_date,
    to_date(salespostdate, 'MM/DD/YYYY HH24:MI:SS')::date            as sales_post_date,
    senderlocationid::integer                                       as sender_location_id,
    receiverlocationid::integer                                     as receiver_location_id,
    upper(trim(payingaccountcodeid::varchar))                      as customer_code,
    pregstcharge::number(12, 2)                                     as pre_gst_charge,
    totalunits::integer                                             as total_units,
    servicetypeid::integer                                          as service_type_id
from {{ source('staging', 'FactConsignment') }}

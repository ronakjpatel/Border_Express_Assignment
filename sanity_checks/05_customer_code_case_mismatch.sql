-- Does every customer_code on FactConsignment have a matching row in DimCustomer? 

-- Step 1: fact rows with no case-sensitive match in DimCustomer
select
    f.invoice_id,
    f.consignmentnumber as consignment_number,
    f.payingaccountcodeid as customer_code_on_fact,
    f.pregstcharge as pre_gst_charge
from RESIDENTIAL_SURCHARGE.staging.FactConsignment f
left join RESIDENTIAL_SURCHARGE.staging.DimCustomer c
    on f.payingaccountcodeid = c.payingaccountcodeid
where c.payingaccountcodeid is null;

-- Step2:check whether that code exists in DimCustomer under different casing
select
    payingaccountcodeid as customer_code_on_dim,
    customernamerg as customer_name
from RESIDENTIAL_SURCHARGE.staging.DimCustomer
where upper(payingaccountcodeid) = 'DIA9';

-- Step1 returns exactly one orphan row (customer_code = 'DIA9'). Step 2 confirms DimCustomer
-- does have that customer, just stored as lowercase 'dia9' - every other code in the table is
-- uppercase (BOC59, DAL9, YAM9, etc.), which reads as a one-off data entry typo rather than a
-- systemic case convention difference. Fixing with upper(trim(...)) on both sides of the join
-- in bronze (stg_dim_customer.sql, stg_fact_consignment.sql), without touching the raw source
-- table.

{{ config(enabled = var('pmpm_enabled',var('tuva_packages_enabled',True)) ) }}

with medical as 
(
    select
        patient_id
       ,extract(year from claim_end_date) as year
       ,lpad(cast(extract(month from claim_end_date) as string),2,'0') as month
       ,cast(cast(extract(year from claim_end_date) as string) || lpad(cast(extract(month from claim_end_date) as string),2,'0') AS int) AS year_month
       ,claim_type
       ,paid_amount
    from {{ var('medical_claim') }}
)
, pharmacy as 
(
    select
        patient_id
        ,extract(year from dispensing_date) as year
        ,lpad(cast(extract(month from dispensing_date) as string),2,'0') as month
        ,cast(cast(extract(year from dispensing_date) as string) || lpad(cast(extract(month from dispensing_date) as string),2,'0') AS int) AS year_month
        ,cast('pharmacy' as string) as claim_type
        ,IFNULL(cast(paid_amount as decimal),0) as paid_amount
    from {{ var('pharmacy_claim') }}
)

select 
    patient_id
    ,claim_type
    ,year_month
    ,count(*) as count_claims
    ,sum(paid_amount) as spend
from medical
group by 
    patient_id
    ,claim_type
    ,year_month

union all

select 
    patient_id
    ,claim_type
    ,year_month
    ,count(*) as count_claims
    ,sum(paid_amount) as spend
from pharmacy
group by 
    patient_id
    ,claim_type
    ,year_month
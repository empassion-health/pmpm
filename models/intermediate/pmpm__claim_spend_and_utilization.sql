{{ config(enabled = var('pmpm_enabled',var('tuva_packages_enabled',True)) ) }}

with medical as 
(
    select
        patient_id
       ,claim_id
       ,extract(year from claim_end_date) as year
       ,lpad(cast(extract(month from claim_end_date) as string),2,'0') as month
       ,cast(cast(extract(year from claim_end_date) as string) || lpad(cast(extract(month from claim_end_date) as string),2,'0') AS int) AS year_month
       ,claim_type
       ,paid_amount
       ,max_claim_effective_date
    from {{ var('medical_claim') }}
)

, medical_claim_encounter_mapping as (
    select distinct
        patient_id
        ,claim_id
        ,encounter_type
    from {{ ref('claims_preprocessing__encounter_id') }}
)

, medical_encounter_mapped as (
    select
        m.patient_id
        ,m.year
        ,m.month
        ,m.year_month
        ,m.claim_type
        ,em.encounter_type
        ,m.paid_amount
        ,m.max_claim_effective_date
    from medical m
        left join medical_claim_encounter_mapping em
        ON m.patient_id = em.patient_id
        AND m.claim_id = em.claim_id
)
, pharmacy as 
(
    select
        patient_id
        ,extract(year from dispensing_date) as year
        ,lpad(cast(extract(month from dispensing_date) as string),2,'0') as month
        ,cast(cast(extract(year from dispensing_date) as string) || lpad(cast(extract(month from dispensing_date) as string),2,'0') AS int) AS year_month
        ,cast('pharmacy' as string) as claim_type
        ,'pharmacy' as encounter_type
        ,paid_amount
    from {{ var('pharmacy_claim') }}
)

select 
    patient_id
    ,claim_type
    ,year_month
    ,encounter_type
    ,max_claim_effective_date
    ,count(*) as count_claims
    ,sum(paid_amount) as spend
from medical_encounter_mapped
group by 
    patient_id
    ,claim_type
    ,year_month
    ,encounter_type
    ,max_claim_effective_date

union all

select 
    patient_id
    ,claim_type
    ,year_month
    ,encounter_type
    ,cast(NULL as date) as max_claim_effective_date
    ,count(*) as count_claims
    ,sum(paid_amount) as spend
from pharmacy
group by 
    patient_id
    ,claim_type
    ,year_month
    ,encounter_type
    ,max_claim_effective_date
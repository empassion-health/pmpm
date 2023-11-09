{{ config(enabled = var('pmpm_enabled',var('tuva_packages_enabled',True)) ) }}

with src as
         (select
              patient_id,
              -- member_id,
              enrollment_start_date as start_date,
              enrollment_end_date as end_date,
              payer,
              payer_type,
              max_claim_effective_date
              -- dual_status_code,
              -- medicare_status_code
          from  {{ var('eligibility') }}
         )
, months as (
    select 1 as month
    union all
    select 2 as month
    union all
    select 3 as month
    union all
    select 4 as month
    union all
    select 5 as month
    union all
    select 6 as month
    union all
    select 7 as month
    union all
    select 8 as month
    union all
    select 9 as month
    union all
    select 10 as month
    union all
    select 11 as month
    union all
    select 12 as month)
,years as (
    select 2013 as year
    union all
    select 2014 as year
    union all
    select 2015 as year
    union all
    select 2016 as year
    union all
    select 2017 as year
    union all
    select 2018 as year
    union all
    select 2019 as year
    union all
    select 2020 as year
    union all
    select 2021 as year
    union all
    select 2022 as year
    union all
    select 2023 as year)
,dates as (
    select
        year
        ,month
        ,cast(cast(year as string)||'-'||cast(month as string)||'-01' as date) as month_start
        ,date_add(date_add(cast(cast(year as string)||'-'||cast(month as string)||'-01' as date), INTERVAL 1 MONTH), INTERVAL -1 DAY) as month_end
    from years
    cross join months
)
select distinct 
    patient_id,
    -- member_id,
    cast(concat(year,lpad(cast(month as string),2,'0')) as int) as year_month,
    year,
    lpad(cast(month as string),2,'0') as month,
    month_start,
    month_end,
    -- start_date,
    -- end_date,
    payer,
    payer_type,
    max_claim_effective_date
    -- dual_status_code,
    -- medicare_status_code
from src
inner join dates
    on src.start_date <= dates.month_end 
    and  src.end_date >= dates.month_start
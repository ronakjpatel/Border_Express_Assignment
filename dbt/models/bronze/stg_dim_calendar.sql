-- Bronze layer: 1:1 with DimCalender, renamed to snake_case with explicit types.
select
    date_id::date                                       as calendar_date,
    is_weekday::boolean                                 as is_weekday,
    financial_year::integer                             as financial_year,
    day::integer                                        as day_of_month,
    fkdayofweek::integer                                as day_of_week_number,
    financial_quarter_number::integer                   as financial_quarter_number,
    financial_month::integer                            as financial_month,
    financial_week::integer                             as financial_week,
    financial_day_of_the_year::integer                  as financial_day_of_the_year,
    financial_month_sequential_id::integer              as financial_month_sequential_id,
    day_of_week_short_name::varchar                     as day_of_week_short_name,
    financial_year_range::varchar                       as financial_year_range,
    financial_month_short_name::varchar                 as financial_month_short_name,
    financial_month_with_year::varchar                  as financial_month_with_year,
    financial_year_month_short::integer                 as financial_year_month_short,
    financial_quarter_with_year::varchar                as financial_quarter_with_year,
    financial_year_and_quarter_short::integer           as financial_year_and_quarter_short,
    week_ending_date::date                              as week_ending_date
from {{ source('staging', 'DimCalender') }}

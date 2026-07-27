
select
    to_number(to_char(calendar_date, 'YYYYMMDD')) as date_sk,
    calendar_date,
    is_weekday,
    financial_year,
    day_of_month,
    day_of_week_number,
    day_of_week_short_name,
    financial_quarter_number,
    financial_month,
    financial_week,
    financial_day_of_the_year,
    financial_month_sequential_id,
    financial_year_range,
    financial_month_short_name,
    financial_month_with_year,
    financial_year_month_short,
    financial_quarter_with_year,
    financial_year_and_quarter_short,
    week_ending_date
from {{ ref('stg_dim_calendar') }}

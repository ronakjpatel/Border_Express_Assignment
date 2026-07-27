-- One row per surcharge tier, plus an unknown member.
-- The unknown member catches consignments that match no tier (the 2 rows with total_units = -1).
-- Without it those facts carry an unresolvable FK and drop out of any visual sliced by unit
-- tier, so their charges silently vanish from the totals. Its SK comes from surrogate_key(null)
-- rather than from unit_surcharge_id, so it lines up with what the fact generates when
-- unit_surcharge_id is null - keep the two in sync if the macro's sentinel ever changes.
with tiers as (
    select
        {{ surrogate_key(['unit_surcharge_id']) }} as unit_surcharge_sk,
        unit_surcharge_id,
        unit_from,
        unit_to,
        surcharge_amount,
        case
            when unit_from = unit_to then unit_from::varchar || ' units'
            when unit_to >= 9999 then unit_from::varchar || '+ units'
            else unit_from::varchar || '-' || unit_to::varchar || ' units'
        end as unit_tier_label
    from {{ ref('stg_dim_unit_surcharge') }}
),

unknown_member as (
    select
        {{ surrogate_key(['null']) }}    as unit_surcharge_sk,
        -1::integer                      as unit_surcharge_id,
        null::integer                    as unit_from,
        null::integer                    as unit_to,
        0::number(10, 2)                 as surcharge_amount,
        'Unknown / no tier'::varchar     as unit_tier_label
)

select * from tiers
union all
select * from unknown_member

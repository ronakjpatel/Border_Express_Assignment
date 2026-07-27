-- Builds a deterministic md5 surrogate key from one or more fields.
-- Every field is cast to varchar and nulls are swapped for a sentinel before concatenating:
-- in Snowflake `null || '-' || 'x'` is null, so without this a single null input would produce
-- a null SK and the fact-to-dim join would silently drop rows instead of failing a not_null test.
-- Same approach dbt_utils.generate_surrogate_key takes.
{% macro surrogate_key(fields) %}
{%- set safe_fields = [] -%}
{%- for field in fields -%}
    {%- do safe_fields.append("coalesce(" ~ field ~ "::varchar, '_sk_null_')") -%}
{%- endfor -%}
md5({{ safe_fields | join(" || '-' || ") }})
{%- endmacro %}

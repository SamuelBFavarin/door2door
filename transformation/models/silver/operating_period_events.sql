{{ config(
    materialized='table',
    tags=['daily']
)}}


SELECT 
    api_events.data.id              AS event_id,
    api_events.organization_id,
    api_events.event                AS event_type,
    api_events.data.start           AS operating_period_started_at,
    api_events.data.finish          AS operating_period_finished_at,
    api_events.at                   AS event_created_at,
FROM {{ source('bronze', 'api_events') }} AS api_events
WHERE api_events.on = "operating_period"
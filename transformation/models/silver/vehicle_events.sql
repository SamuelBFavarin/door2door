{{ config(
    materialized='table',
    tags=['daily']
)}}


SELECT 
    api_events.data.id              AS event_id,
    api_events.organization_id,
    api_events.event                AS event_type,
    api_events.data.location.lat    AS latitude,
    api_events.data.location.lng    AS longitude,    	
    api_events.data.location.at     AS location_updated_at,
    api_events.at                   AS event_created_at,
FROM {{ source('bronze', 'api_events') }} AS api_events
WHERE api_events.on = "vehicle"
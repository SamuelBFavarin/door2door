{{ config(
    materialized='table',
    tags=['daily']
)}}


SELECT 
    data.id AS event_id,
    organization_id,
    data.location.lat AS latitude,
    data.location.lng AS longitude,    	
    data.location.at AS created_at
FROM {{ source('bronze', 'api_events') }}
WHERE event = "update"
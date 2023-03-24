{{ config(
    materialized='table',
    tags=['daily']
)}}

-- EVENTS CTE
-- Here we'll join vehicle and operating_period and calc the row_num
WITH events AS (
  SELECT
    vehicle_events.event_id             AS vehicle_id,
    operating_period_events.event_id    AS operating_period_id,
    vehicle_events.organization_id      AS organization_id,
    vehicle_events.latitude             AS latitude,
    vehicle_events.longitude            AS longitude,
    vehicle_events.location_updated_at  AS location_updated_at,
    ROW_NUMBER() OVER (
      PARTITION BY vehicle_events.event_id, operating_period_events.event_id ORDER BY location_updated_at DESC
    ) AS row_num_desc,
    ROW_NUMBER() OVER (
      PARTITION BY vehicle_events.event_id, operating_period_events.event_id  ORDER BY location_updated_at ASC
    ) AS row_num_asc,
  FROM {{ ref('vehicle_events') }} AS vehicle_events
  JOIN {{ ref('operating_period_events') }} AS operating_period_events
    ON location_updated_at BETWEEN operating_period_started_at AND operating_period_finished_at
    AND vehicle_events.organization_id = operating_period_events.organization_id
  WHERE
    vehicle_events.event_type = "update"
),

-- LAST EVENT
-- A cte with the last events of the vehicles
last_event AS (
  SELECT *
  FROM events
  WHERE row_num_desc = 1
),

-- FIRST EVENT
-- A cte with the first events of the vehicles
first_event AS (
  SELECT *
  FROM events
  WHERE row_num_asc = 1
),

-- EVENTS DISTANCES
-- A cte used to calc the distance between the evets
events_distances AS (
  SELECT
    e1.vehicle_id,
    e1.operating_period_id,
    e1.organization_id,
    e1.location_updated_at  AS location_updated_at1,
    e1.latitude             AS latitude1,
    e1.longitude            AS longitude1,
    e2.latitude             AS latitude2,
    e2.longitude            AS longitude2,
    ST_DISTANCE(
      ST_GEOGPOINT(e1.longitude, e1.latitude), ST_GEOGPOINT(e2.longitude, e2.latitude)
    ) AS distance_meters
  FROM events e1
  JOIN events e2 
    ON e1.vehicle_id = e2.vehicle_id 
    AND e1.operating_period_id = e2.operating_period_id 
    AND e1.row_num_desc = e2.row_num_desc - 1
)

-- FINAL SQL
-- This table will contais the event metrics per vehicle
SELECT 
  CONCAT(
    events_distances.vehicle_id, '_', 
    events_distances.operating_period_id)  AS sk_vehicle_ops_metrics,
  events_distances.vehicle_id             AS vehicle_id,
  events_distances.operating_period_id    AS operating_period_id,
  SUM(distance_meters)                    AS total_distance_meter,
  COUNT(1)                                AS total_vehicles_updates,
  MIN(first_event.latitude)               AS first_event_latitude,
  MIN(first_event.longitude)              AS first_event_longitude,
  MIN(last_event.latitude)                AS last_event_latitude,
  MIN(last_event.longitude)               AS last_event_longitude,
  MIN(location_updated_at1)               AS vehicle_started_at,
  MAX(location_updated_at1)               AS vehicle_finished_at
FROM events_distances
JOIN first_event
  ON events_distances.vehicle_id = first_event.vehicle_id
  AND events_distances.operating_period_id = first_event.operating_period_id
JOIN last_event
  ON events_distances.vehicle_id = last_event.vehicle_id
  AND events_distances.operating_period_id = last_event.operating_period_id
GROUP BY events_distances.vehicle_id, 
          events_distances.operating_period_id
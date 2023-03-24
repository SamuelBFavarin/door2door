-- The average distance traveled by our vehicles during an operating period.
SELECT 
  operating_period_id,
  COUNT(1)                  AS total_vehicles,
  AVG(total_distance_meter) AS avg_vehicles_travel_distances
FROM {{ ref('vehicle_operations_metrics') }}
GROUP BY operating_period_id;
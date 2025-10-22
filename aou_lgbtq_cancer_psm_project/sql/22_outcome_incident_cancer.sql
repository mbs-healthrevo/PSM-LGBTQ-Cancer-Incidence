-- 22_outcome_incident_cancer.sql
-- First qualifying invasive cancer after index; optional confirmatory evidence window
CREATE OR REPLACE TABLE `${AOU_PROJECT}.${WORK_SCHEMA}.incident_cancer` AS
WITH candidates AS (
  SELECT b.person_id, c.condition_start_date AS event_date
  FROM `${AOU_PROJECT}.${WORK_SCHEMA}.base_cohort` b
  JOIN `${AOU_PROJECT}.${AOU_DATASET}.condition_occurrence` c
    ON c.person_id = b.person_id
  WHERE c.condition_start_date >= b.index_date
    AND c.condition_concept_id IN UNNEST([0])  -- malignant neoplasm
),
confirm AS (
  SELECT person_id, MIN(event_date) AS first_event_date
  FROM candidates
  GROUP BY person_id
)
SELECT person_id, first_event_date
FROM confirm;

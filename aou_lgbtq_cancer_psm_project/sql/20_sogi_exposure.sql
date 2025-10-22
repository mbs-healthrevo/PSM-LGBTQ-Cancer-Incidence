-- 20_sogi_exposure.sql
-- Creates WORK_SCHEMA.sogi_flags with one row per person: lgbtq flag and index date
CREATE OR REPLACE TABLE `${AOU_PROJECT}.${WORK_SCHEMA}.sogi_flags` AS
WITH sogi AS (
  SELECT
    p.person_id,
    ANY_VALUE(p.year_of_birth) AS yob,
    ANY_VALUE(p.sex_at_birth_concept_id) AS sex_at_birth_concept_id,
    -- Simplified SOGI derivation (replace predicates with concept IDs)
    MAX(IF(o.observation_concept_id IN UNNEST([0]), 1, 0)) AS hetero_any,
    MAX(IF(o.observation_concept_id IN UNNEST([0]), 1, 0)) AS lgb_any,
    MAX(IF(o.observation_concept_id IN UNNEST([0]), 1, 0)) AS cis_any,
    MAX(IF(o.observation_concept_id IN UNNEST([0]), 1, 0)) AS trans_nb_any,
    MIN(o.observation_date) AS first_sogi_date
  FROM `${AOU_PROJECT}.${AOU_DATASET}.person` p
  LEFT JOIN `${AOU_PROJECT}.${AOU_DATASET}.observation` o
    ON o.person_id = p.person_id
  GROUP BY person_id
)
SELECT
  person_id,
  CASE WHEN lgb_any=1 OR trans_nb_any=1 THEN 1 
       WHEN hetero_any=1 AND cis_any=1 THEN 0
       ELSE NULL END AS lgbtq,
  first_sogi_date AS index_date
FROM sogi
WHERE first_sogi_date IS NOT NULL;

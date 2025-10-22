-- 21_base_cohort.sql
-- Applies wash-in, cancer-free baseline, and data density rules.
CREATE OR REPLACE TABLE `${AOU_PROJECT}.${WORK_SCHEMA}.base_cohort` AS
WITH visits AS (
  SELECT person_id, visit_start_date
  FROM `${AOU_PROJECT}.${AOU_DATASET}.visit_occurrence`
),
density AS (
  SELECT s.person_id,
         COUNTIF(visit_start_date BETWEEN DATE_SUB(s.index_date, INTERVAL @WASHIN_YEARS YEAR) AND s.index_date) AS visits_prewash,
         COUNTIF(visit_start_date BETWEEN s.index_date AND DATE_ADD(s.index_date, INTERVAL 1 YEAR)) AS visits_post
  FROM `${AOU_PROJECT}.${WORK_SCHEMA}.sogi_flags` s
  JOIN visits v USING (person_id)
  GROUP BY person_id
),
cancer_prev AS (
  SELECT DISTINCT s.person_id
  FROM `${AOU_PROJECT}.${WORK_SCHEMA}.sogi_flags` s
  JOIN `${AOU_PROJECT}.${AOU_DATASET}.condition_occurrence` c USING (person_id)
  WHERE c.condition_start_date BETWEEN DATE_SUB(s.index_date, INTERVAL @WASHIN_YEARS YEAR) AND s.index_date
    AND c.condition_concept_id IN UNNEST([0])  -- malignant neoplasm concepts
)
SELECT s.person_id, s.lgbtq, s.index_date
FROM `${AOU_PROJECT}.${WORK_SCHEMA}.sogi_flags` s
LEFT JOIN density d USING (person_id)
LEFT JOIN cancer_prev p USING (person_id)
WHERE p.person_id IS NULL
  AND d.visits_prewash >= 2
  AND d.visits_post >= 1;

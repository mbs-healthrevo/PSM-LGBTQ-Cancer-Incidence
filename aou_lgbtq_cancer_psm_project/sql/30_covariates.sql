-- 30_covariates.sql
-- Builds person-level analysis table with covariates and time-to-event
CREATE OR REPLACE TABLE `${AOU_PROJECT}.${WORK_SCHEMA}.analysis_person` AS
WITH base AS (
  SELECT b.person_id, b.lgbtq, b.index_date,
         EXTRACT(YEAR FROM b.index_date) AS index_year
  FROM `${AOU_PROJECT}.${WORK_SCHEMA}.base_cohort` b
),
demo AS (
  SELECT p.person_id,
         EXTRACT(YEAR FROM CURRENT_DATE()) - p.year_of_birth AS age,
         p.sex_at_birth_concept_id AS sab,
         p.race_concept_id AS race,
         p.ethnicity_concept_id AS ethnicity
  FROM `${AOU_PROJECT}.${AOU_DATASET}.person` p
),
util AS (
  SELECT person_id,
         COUNT(1) AS visit_count,
         COUNTIF(visit_start_date BETWEEN DATE_SUB(b.index_date, INTERVAL 2 YEAR) AND b.index_date) AS visit_count_washin
  FROM `${AOU_PROJECT}.${AOU_DATASET}.visit_occurrence` v
  JOIN base b USING (person_id)
  GROUP BY person_id
),
bmi AS (
  SELECT person_id,
         ANY_VALUE(value_as_number) AS bmi
  FROM `${AOU_PROJECT}.${AOU_DATASET}.measurement`
  WHERE measurement_concept_id IN (3038553)  -- BMI
  GROUP BY person_id
),
outcomes AS (
  SELECT a.person_id,
         IFNULL(i.first_event_date, NULL) AS event_date,
         (SELECT MIN(death_date) FROM `${AOU_PROJECT}.${AOU_DATASET}.death` d WHERE d.person_id=a.person_id) AS death_date
  FROM base a
  LEFT JOIN `${AOU_PROJECT}.${WORK_SCHEMA}.incident_cancer` i USING (person_id)
)
SELECT
  a.person_id,
  a.lgbtq,
  a.index_date,
  a.index_year,
  SAFE_CAST(d.age AS INT64) AS age,
  d.sab AS sex_at_birth,
  CONCAT(CAST(d.race AS STRING),'-',CAST(d.ethnicity AS STRING)) AS race_eth,
  u.visit_count AS visit_count,
  b.bmi AS bmi,
  -- Event indicators and time
  IF(o.event_date IS NOT NULL, 1, 0) AS event,
  -- fstatus: 1=cancer, 2=death (competing)
  CASE WHEN o.event_date IS NOT NULL THEN 1
       WHEN o.event_date IS NULL AND o.death_date IS NOT NULL THEN 2
       ELSE 0 END AS fstatus,
  DATE_DIFF(COALESCE(o.event_date, o.death_date, DATE_ADD(a.index_date, INTERVAL 1825 DAY)), a.index_date, DAY) AS time,
  -- stub placeholders
  0 AS preventive_any,
  'UNK' AS insurance,
  'UNK' AS region,
  0 AS cci,
  'site_stub' AS site_id
FROM base a
LEFT JOIN demo d USING (person_id)
LEFT JOIN util u USING (person_id)
LEFT JOIN bmi  b USING (person_id)
LEFT JOIN outcomes o USING (person_id);

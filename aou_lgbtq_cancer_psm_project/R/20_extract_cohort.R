source('R/01_config.R'); library(DBI); library(glue); library(bigrquery); library(dplyr)

con <- bq_con()
wcon <- writeable_con()

# Materialize SOGI exposure flags and index date per person
sql_sogi <- readLines('sql/20_sogi_exposure.sql')
DBI::dbExecute(wcon, glue::glue_sql(sql_sogi, .con = wcon))

# Apply wash-in, cancer-free baseline, and data density rules
sql_cohort <- readLines('sql/21_base_cohort.sql')
DBI::dbExecute(wcon, glue::glue_sql(sql_cohort, .con = wcon))

# Outcome candidate events (with confirmatory evidence)
sql_outcome <- readLines('sql/22_outcome_incident_cancer.sql')
DBI::dbExecute(wcon, glue::glue_sql(sql_outcome, .con = wcon))

message('Cohort extraction complete. Tables created in: ', WORK_SCHEMA)

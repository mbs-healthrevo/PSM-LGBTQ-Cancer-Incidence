# Configuration for AoU Workbench (BigQuery)
# Edit these three lines to match your workspace datasets
AOU_PROJECT   <- Sys.getenv('GOOGLE_CLOUD_PROJECT', unset = 'psm-aou-project')  
AOU_DATASET   <- 'cdr_YYYYMMDD'    # e.g., 'rdr2024q4rX' or similar controlled tier dataset ID
WORK_SCHEMA   <- 'work_temp'       # writeable dataset for tables

# Analysis parameters
MIN_AGE <- 18
MAX_AGE <- 85
WASHIN_YEARS <- 2
FOLLOWUP_GAP_DAYS <- 365  # censor after this gap without encounters

# Primary analysis flags
CALIPER_SD <- 0.2
MATCH_RATIO <- 1

# Output paths
OUT_DIR <- 'outputs'
FIG_DIR <- file.path(OUT_DIR, 'figures')
TAB_DIR <- file.path(OUT_DIR, 'tables')

# Helpers
bq_con <- function(){
  DBI::dbConnect(
    bigrquery::bigquery(),
    project = AOU_PROJECT,
    dataset = AOU_DATASET,
    use_legacy_sql = FALSE
  )
}
writeable_con <- function(){
  DBI::dbConnect(
    bigrquery::bigquery(),
    project = AOU_PROJECT,
    dataset = WORK_SCHEMA,
    use_legacy_sql = FALSE
  )
}

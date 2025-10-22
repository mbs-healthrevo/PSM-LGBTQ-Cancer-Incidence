source('R/01_config.R'); library(DBI); library(dplyr); library(glue); library(dbplyr)

con <- bq_con()

# --- SOGI concept scaffolds (replace with finalized concept IDs) ---
# These are placeholders; use OHDSI ATLAS / Athena to populate.
sogi_orientation_hetero <- c(0)   # concept_ids for 'heterosexual / straight'
sogi_orientation_lgb    <- c(0)   # concept_ids for gay/lesbian/bisexual/queer/other
sogi_gender_cis         <- c(0)   # concept_ids mapping to 'man'/'woman' aligned with sex at birth
sogi_gender_trans_nb    <- c(0)   # concept_ids for transgender / nonbinary

# Cancer SNOMED roots (malignant neoplasm); exclude non-melanoma skin
cancer_condition_concepts <- c(0) # <- fill with valid concept_ids for malignant neoplasms

# Oncology confirmatory evidence
oncology_drug_atc <- c('L01','L02')   # ATC prefixes
cancer_proc_cpt   <- c()              # CPT/HCPCS codes for cancer-directed procedures

# Save placeholders to CSV for versioning
readr::write_csv(data.frame(concept_id = sogi_orientation_hetero), 'data/sogi_orientation_hetero.csv')
readr::write_csv(data.frame(concept_id = sogi_orientation_lgb),    'data/sogi_orientation_lgb.csv')
readr::write_csv(data.frame(concept_id = sogi_gender_cis),         'data/sogi_gender_cis.csv')
readr::write_csv(data.frame(concept_id = sogi_gender_trans_nb),    'data/sogi_gender_trans_nb.csv')
readr::write_csv(data.frame(concept_id = cancer_condition_concepts),'data/cancer_condition_concepts.csv')

message('Concept placeholders written. Replace with finalized IDs.')

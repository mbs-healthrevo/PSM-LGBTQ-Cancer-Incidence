[README.md](https://github.com/user-attachments/files/23059091/README.md)
# AoU LGBTQ vs Cis-Het Cancer Incidence — PSM Analysis (R + BigQuery)

This is a plug-and-play scaffold for the All of Us (AoU) Researcher Workbench. 
It builds cohorts from OMOP tables, performs propensity score matching, 
estimates incidence rate ratios (Poisson/NB), runs Cox/Fine-Gray sensitivities, 
and emits tables/figures suitable for journals.

## How to run (Workbench RStudio)
1) Open RStudio in AoU Workbench workspace.
2) Install packages once:
   ```r
   source('R/00_setup_packages.R')
   ```
3) Configure your dataset IDs and project in `R/01_config.R` (CDR, dataset, project).
4) Build concept sets and extract cohorts:
   ```r
   source('R/10_build_concepts.R')
   source('R/20_extract_cohort.R')   # runs BigQuery SQL to materialize cohorts
   ```
5) Compute covariates and PS, match, and run models:
   ```r
   source('R/30_covariates_and_ps.R')
   source('R/40_models_primary_secondary.R')
   source('R/50_sensitivity_robustness.R')
   source('R/60_figures_tables.R')
   ```
6) Render report:
   ```r
   quarto::render('report/analysis_report.qmd')
   ```

## Notes
- SQL is written in BigQuery Standard SQL and parameterized via glue strings.
- All outputs land in `outputs/`. Apply AoU disclosure rules before export.
- Replace concept set stubs with finalized concept IDs before analysis.

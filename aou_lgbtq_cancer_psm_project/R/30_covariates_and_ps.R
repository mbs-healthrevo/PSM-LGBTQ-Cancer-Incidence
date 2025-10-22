source('R/01_config.R')
library(DBI); library(dplyr); library(glue); library(bigrquery)
library(MatchIt); library(cobalt); library(tableone); library(splines)

wcon <- writeable_con()
# Pull analysis-ready person-level data with covariates (built in SQL)
sql_cov <- readLines('sql/30_covariates.sql')
DBI::dbExecute(wcon, glue::glue_sql(sql_cov, .con = wcon))

dat <- DBI::dbReadTable(wcon, 'analysis_person')

# Propensity score
covars <- c('age','sex_at_birth','race_eth','bmi','smoking','alcohol_disorder',
            'cci','visit_count','preventive_any','insurance','region','index_year','site_id')
dat$age_s <- dat$age
ps_form <- as.formula(paste(
  'lgbtq ~ ns(age_s, df=4) +', 
  paste(setdiff(covars, 'age'), collapse=' + ')
))

m.out <- matchit(ps_form, data=dat, method='nearest', distance='logit',
                 caliper=CALIPER_SD, ratio=MATCH_RATIO, replace=FALSE)
matched <- MatchIt::match.data(m.out)

# Balance diagnostics
smd <- cobalt::love.plot(m.out, thresholds=c(m=0.1), var.order='unadjusted')
ggplot2::ggsave(file.path(FIG_DIR, 'love_plot.png'), smd, width=8, height=6, dpi=300)

readr::write_csv(matched, file.path('outputs','matched_person.csv'))
saveRDS(m.out, file.path('outputs','ps_matchit.rds'))

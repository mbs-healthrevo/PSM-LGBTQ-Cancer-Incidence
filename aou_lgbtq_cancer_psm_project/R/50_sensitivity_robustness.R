source('R/01_config.R'); library(DBI); library(dplyr); library(WeightIt); library(survey)
library(readr); library(ggplot2)

# Read full analysis person table (before matching)
wcon <- writeable_con()
dat <- DBI::dbReadTable(wcon, 'analysis_person')

covars <- c('age','sex_at_birth','race_eth','bmi','smoking','alcohol_disorder',
            'cci','visit_count','preventive_any','insurance','region','index_year','site_id')
dat$age_s <- dat$age
form <- as.formula(paste('lgbtq ~ splines::ns(age_s,4) +', paste(setdiff(covars,'age'), collapse=' + ')))

w <- WeightIt::weightit(form, data=dat, method='overlap')
dat$w <- w$weights
des <- svydesign(ids=~1, weights=~w, data=dat)
fit <- svyglm(event ~ lgbtq + offset(log(time/365.25)), design=des, family=quasipoisson())
est <- coef(summary(fit))['lgbtq',]
irr <- exp(est['Estimate']); lcl <- exp(est['Estimate'] - 1.96*est['Std. Error']); ucl <- exp(est['Estimate'] + 1.96*est['Std. Error'])
readr::write_csv(data.frame(method='Overlap weighting', IRR=irr, LCL=lcl, UCL=ucl, p=est['Pr(>|t|)']),
                 file.path(TAB_DIR,'sensitivity_overlap_weighting.csv'))

source('R/01_config.R'); library(readr); library(dplyr); library(MASS)
library(sandwich); library(lmtest); library(survival); library(ggplot2)

matched <- readr::read_csv(file.path('outputs','matched_person.csv'), show_col_types = FALSE)
# Expect columns: person_id, lgbtq (0/1), event (0/1), time (days), fstatus (0/1/2), subclass (pair)

matched$py <- matched$time / 365.25

# Poisson (check overdispersion)
fit_pois <- glm(event ~ lgbtq, offset=log(py), family=poisson(), data=matched)
phisq <- sum(residuals(fit_pois, type='pearson')^2) / fit_pois$df.residual
use_nb <- is.finite(phisq) && phisq > 1.5

if (use_nb){
  fit <- MASS::glm.nb(event ~ lgbtq + offset(log(py)), data=matched)
  vc <- sandwich::vcovCL(fit, cluster = ~ subclass)
  est <- coef(fit)['lgbtq']
} else {
  fit <- fit_pois
  vc <- sandwich::vcovCL(fit, cluster = ~ subclass)
  est <- coef(fit)['lgbtq']
}
ct <- lmtest::coeftest(fit, vcov.=vc)
irr <- exp(ct['lgbtq','Estimate']); lcl <- exp(ct['lgbtq','Estimate'] - 1.96*ct['lgbtq','Std. Error'])
ucl <- exp(ct['lgbtq','Estimate'] + 1.96*ct['lgbtq','Std. Error']); p <- ct['lgbtq','Pr(>|z|)']

res_tab <- data.frame(model = ifelse(use_nb,'NB','Poisson'),
                      IRR = irr, LCL = lcl, UCL = ucl, p = p)
readr::write_csv(res_tab, file.path(TAB_DIR,'primary_irr.csv'))

# Cox
cox <- coxph(Surv(time, event==1) ~ lgbtq + cluster(subclass), data=matched)
csum <- summary(cox)
hr <- exp(coef(cox)['lgbtq']); se <- csum$coef['lgbtq','se(coef)']
hr_l <- exp(log(hr) - 1.96*se); hr_u <- exp(log(hr) + 1.96*se)
readr::write_csv(data.frame(HR=hr, LCL=hr_l, UCL=hr_u, p=csum$coef['lgbtq','Pr(>|z|)']),
                 file.path(TAB_DIR,'secondary_hr.csv'))

# Crude incidence bar
rates <- matched %>% group_by(lgbtq) %>% summarize(events=sum(event), py=sum(py), rate=events/py*1000)
ggplot(rates, aes(x=factor(lgbtq, labels=c('Cis-het','LGBTQ')), y=rate)) + 
  geom_col() + labs(x='', y='Incidence per 1,000 PY', title='Crude Cancer Incidence') +
  theme_minimal(base_size=12)
ggsave(file.path(FIG_DIR,'crude_incidence.png'), width=5, height=4, dpi=300)

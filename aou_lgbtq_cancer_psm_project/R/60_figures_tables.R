source('R/01_config.R'); library(readr); library(dplyr); library(ggplot2); library(cobalt)
library(gridExtra)

# Load results
irr <- readr::read_csv(file.path('outputs','tables','primary_irr.csv'), show_col_types = FALSE)
hr  <- readr::read_csv(file.path('outputs','tables','secondary_hr.csv'), show_col_types = FALSE)

# Forest-style one-liners
irr$label <- sprintf('IRR %.2f (%.2f, %.2f)', irr$IRR, irr$LCL, irr$UCL)
hr$label  <- sprintf('HR %.2f (%.2f, %.2f)',  hr$HR,  hr$LCL,  hr$UCL)

writeLines(knitr::kable(irr), con = file.path('outputs','tables','primary_irr.md'))
writeLines(knitr::kable(hr),  con = file.path('outputs','tables','secondary_hr.md'))

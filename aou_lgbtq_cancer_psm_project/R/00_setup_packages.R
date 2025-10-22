# Install/load packages (run once)
pkgs <- c(
  'DBI','bigrquery','dplyr','dbplyr','stringr','glue','tidyr','lubridate','readr',
  'MatchIt','WeightIt','cobalt','tableone','survival','sandwich','lmtest','MASS',
  'cmprsk','splines','ggplot2','ggpubr','data.table','quarto'
)
install_if_missing <- function(x){
  if (!requireNamespace(x, quietly = TRUE)) install.packages(x)
  suppressPackageStartupMessages(library(x, character.only = TRUE))
}
invisible(lapply(pkgs, install_if_missing))
message('Packages ready.')

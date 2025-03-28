# helper script that sources all necessary R scripts
# change your local path
path <- "/Users/Samuel/projects/DataFest2025"
setwd(path)
source("settings.R")
files <- list.files(
  "code",
  pattern = "\\.R$",
  full.names = TRUE,
  ignore.case = TRUE,
  recursive = TRUE
)
lapply(files, source)

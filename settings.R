# package setup
packages <- c("tidyverse", "lubridate", "data.table", "xgboost", "mlr3verse", "randomForest", "checkmate")
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

theme_set(theme_minimal())
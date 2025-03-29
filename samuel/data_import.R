# import grid and municipality data
municipal.data <- fread(paste0(path, "/data/raw/municipal_data/municipal_main.csv"))
grid.data <- fread(paste0(path, "/data/raw/grid_data/100m_grid.csv"))

# cross sectional data
cs.hk.2023 <- fread(paste0(path, "/data/raw/HiDrive/cross_section/CampusFile_HK_2023.csv"))
cs.wk.2023 <- fread(paste0(path, "/data/raw/HiDrive/cross_section/CampusFile_WK_2023.csv"))
cs.wm.2023 <- fread(paste0(path, "/data/raw/HiDrive/cross_section/CampusFile_WM_2023.csv"))

# panel data
# panel.hk <- fread(paste0(path, "/data/raw/HiDrive/panel/CampusFile_HK_cities.csv"))
# panel.wk <- fread(paste0(path, "/data/raw/HiDrive/panel/CampusFile_WK_cities.csv"))
# panel.wm <- fread(paste0(path, "/data/raw/HiDrive/panel/CampusFile_WM_cities.csv"))

# description data
cs.summary <- read_xlsx(paste0(path, "/data/raw/HiDrive/cross_section/number_municipalities_cross.xlsx"))
panel.summary <- read_xlsx(paste0(path, "/data/raw/HiDrive/panel/number_observations_panel.xlsx"))
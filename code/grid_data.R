grid.data <- fread(paste0(path, "/data/raw/grid_data/100m_grid.csv"))

grid.data[, `:=` (
  bs_delta = bs_20 / bs_2005,
  pop_delta = pop_20 / pop_05,
  lupp_delta = lupp20 / lupp05
)]

grid.data <- grid.data[!is.na(bs_delta) & !is.na(pop_delta) & !is.na(lupp_delta)]

# set resolution, i.e., 5000 for (5km)^2 grid cells
resolution <- 5000
grid.data[, x_agg := floor(x_map / resolution) * resolution]
grid.data[, y_agg := floor(y_map / resolution) * resolution]

grid.agg <- grid.data[, .(
  bs_delta = mean(bs_delta, na.rm = TRUE),
  pop_delta = mean(pop_delta, na.rm = TRUE),
  lupp_delta = mean(lupp_delta, na.rm = TRUE)
), by = .(x_agg, y_agg)]

# winsorize for plots
winsor <- function(x, lower, upper) pmin(pmax(x, lower), upper)

# calculate winsor limits
low <- 0.01
high <- 0.99
probs <- c(low, high)
bs_quantile <- quantile(grid.agg$bs_delta, probs, na.rm = TRUE)
pop_quantile <- quantile(grid.agg$pop_delta, probs, na.rm = TRUE)
lupp_quantile <- quantile(grid.agg$lupp_delta, probs, na.rm = TRUE)

grid.agg[, `:=`(
  bs_delta = winsor(bs_delta, bs_quantile[1], bs_quantile[2]),
  pop_delta = winsor(pop_delta, pop_quantile[1], pop_quantile[2]),
  lupp_delta = winsor(lupp_delta, lupp_quantile[1], lupp_quantile[2])
)]

# function to create grid cells from 3035 coordinates
createSquarePolygons <- function(x, y, resolution) {
  half <- resolution / 2
  corners <- matrix(c(
    x - half, y - half,
    x + half, y - half,
    x + half, y + half,
    x - half, y + half,
    x - half, y - half
  ),
  ncol = 2, byrow = TRUE)

  st_polygon(list(corners))
}

# add grid information to each row for plotting
grid.agg[, geometry := mapply(createSquarePolygons, x_agg, y_agg, resolution, SIMPLIFY = FALSE)]
grid.agg.sf <- st_sf(grid.agg, crs = 3035)

# plot on map:
ggplot(grid.agg.sf) +
  geom_sf(aes(fill = bs_delta), color = NA) +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "log",
    name = "Built-up area\n(2020/2005)"
  ) +
  coord_sf(crs = st_crs(3035)) +
  labs(
    title = "Change in Built-Up Surface Area (2020/2005)",
    subtitle = expression("Grid cell size: 5km"^2)
  ) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())

# plot on map:
ggplot(grid.agg.sf) +
  geom_sf(aes(fill = pop_delta), color = NA) +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "log",
    name = "Population\n(2020/2005)"
  ) +
  coord_sf(crs = st_crs(3035)) +
  labs(
    title = "Change in Population (2020/2005)",
    subtitle = expression("Grid cell size: 5km"^2)
  ) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())

# plot on map:
ggplot(grid.agg.sf) +
  geom_sf(aes(fill = lupp_delta), color = NA) +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "log",
    name = "LUPP\n(2020/2005)"
  ) +
  coord_sf(crs = st_crs(3035)) +
  labs(
    title = "Change in LUPP (2020/2005)",
    subtitle = expression("Grid cell size: 5km"^2)
  ) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())

municipal.data <- fread(paste0(path, "/data/raw/municipal_data/municipal_main.csv"))

shapes <- st_read(paste0(path, "/data/raw/municipal_data/shapes/vg250_ebenen_0101/VG250_GEM.shp"))
shapes <- shapes %>%
  mutate(AGS = as.numeric(AGS)) %>%
  group_by(AGS) %>%
  summarize(geometry = st_union(geometry), .groups = "drop")

# remove irrelevant columns
municipal.data <- municipal.data[, .(
  AGS,
  bs_2005,
  bs_20,
  pop_2005,
  pop_20,
  lupp2005_MEAN,
  lupp20_MEAN
)]

# get deltas
municipal.data[, `:=` (
  bs_delta = bs_20 / bs_2005,
  pop_delta = pop_20 / pop_2005,
  lupp_delta = lupp20_MEAN / lupp2005_MEAN
)]

municipal.data <- municipal.data[!is.na(bs_delta) & !is.na(pop_delta) & !is.na(lupp_delta)]

winsor <- function(x, lower, upper) pmin(pmax(x, lower), upper)

# calculate winsor limits
low <- 0.01
high <- 0.99
probs <- c(low, high)
bs_quantile <- quantile(municipal.data$bs_delta, probs, na.rm = TRUE)
pop_quantile <- quantile(municipal.data$pop_delta, probs, na.rm = TRUE)
lupp_quantile <- quantile(municipal.data$lupp_delta, probs, na.rm = TRUE)

municipal.data[, `:=`(
  bs_delta = winsor(bs_delta, bs_quantile[1], bs_quantile[2]),
  pop_delta = winsor(pop_delta, pop_quantile[1], pop_quantile[2]),
  lupp_delta = winsor(lupp_delta, lupp_quantile[1], lupp_quantile[2])
)]

# merge shape information into municipal.data
municipal.data.df <- as.data.frame(municipal.data)

merged.data <- municipal.data.df %>%
  left_join(shapes, by = "AGS")

merged.data <- merged.data[!st_is_empty(merged.data$geometry), ]
merged.data.sf <- st_as_sf(merged.data)

# plot bs, pop, and lupp
ggplot(merged.data.sf) +
  geom_sf(aes(fill = bs_delta), color = NA) +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "log",
    name = "Built-up area\n(2020/2005)"
  ) +
  coord_sf(crs = st_crs(3035)) +
  labs(
    title = "Change in Built-Up Surface Area (2020/2005)",
    subtitle = "Administrative level: Municipality (Gemeinde)"
  ) +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
  )

# plot on map:
ggplot(merged.data.sf) +
  geom_sf(aes(fill = pop_delta), color = NA) +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "log",
    name = "Population\n(2020/2005)"
  ) +
  coord_sf(crs = st_crs(3035)) +
  labs(
    title = "Change in Population (2020/2005)",
    subtitle = "Administrative level: Municipality (Gemeinde)"
  ) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())

# plot on map:
ggplot(merged.data.sf) +
  geom_sf(aes(fill = lupp_delta), color = NA) +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "log",
    name = "LUPP\n(2020/2005)"
  ) +
  coord_sf(crs = st_crs(3035)) +
  labs(
    title = "Change in LUPP (2020/2005)",
    subtitle = "Administrative level: Municipality (Gemeinde)"
  ) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())

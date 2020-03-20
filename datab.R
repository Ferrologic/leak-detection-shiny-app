if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse,  leaflet)

bcp_post_tbl <- read_csv("bcp_post_tbl.csv")


bcp_post_tbl %>% 
	group_by(house) %>% 
	summarise(
		bcp_post_prob = max(bcp_post_prob,na.rm = T)
	) %>% 
	ungroup() %>%
	mutate(
		leakage = ifelse(grepl("leak", house), "Yes", "No") %>% 
			as.factor(),
		pred_yes = bcp_post_prob,
		pred_no = 1-bcp_post_prob
	) %>% 
	mutate(leakage = fct_relevel(leakage, "No", after = 1)) -> to_thresh

## get max j-index
to_thresh %>%
	threshold_perf(leakage, pred_yes, thresholds = seq(0.1, 1, by = 0.025)) %>%
	filter(.metric != "distance") %>%
	mutate(group = case_when(
		.metric == "sens" | .metric == "spec" ~ "1",
		TRUE ~ "2"
	)) %>%
	filter(.metric == "j_index") %>%
	filter(.estimate == max(.estimate)) %>%
	pull(.threshold) -> thresh

to_thresh %>% 
	mutate(estimate = ifelse(bcp_post_prob > 0.5, "Yes", "No") %>% 
									as.factor()) %>% 
	mutate(estimate = fct_relevel(estimate, "No", after = 1)) %>%
	dplyr::select(leakage, estimate) %>% 
	yardstick::conf_mat(truth = leakage, estimate = estimate) %>%
	pluck(1) %>%
	as_tibble() %>%
	mutate(correct = ifelse(Prediction == "Yes" & Truth == "Yes" |
																										Prediction == "No" & Truth == "No", "Yes","No" )) %>%
	ggplot(aes( Truth, Prediction, fill = correct)) +
	geom_tile( show.legend = FALSE) +
	geom_text(aes(label = n), color = "white", alpha = 1, size = 8) +
	scale_fill_manual(values = col_sm[4:5]) +
	theme_minimal() +
	labs(
		title = "Confusion matrix BCP analysis",
		subtitle = "Threshold = 0.35, accuracy = 97%"
	) +
	theme(panel.grid.major.x = ggplot2::element_blank(),
							panel.grid.major.y = ggplot2::element_blank())

tibble(
	long_stockholm = rep(18.068602),
	lat_stockholm = rep(59.329315),
	long_area = c(18.045967,17.992630,17.953538,18.144856,18.065390),
	lat_area = c(59.264211,59.286658,59.328705,59.360048,59.442981),
	area = c("area_1", "area_2", "area_3", "area_4", "area_5")
) -> area_coords

bcp_post_tbl %>% 
	select(house) %>% 
	distinct() %>%
	mutate(id = runif(1000,1,1000)) %>% 
	arrange(id) %>% 
	select(-id) %>%
	mutate(area = rep(c("area_1", "area_2",
																					"area_3", "area_4", "area_5"), each = 200)) %>% 
	left_join(area_coords, "area") %>% 
	rowwise() %>%
	mutate(lat_house = rnorm(1,lat_area,0.004 ),
								long_house = rnorm(1,long_area,0.004 )) %>% 
	ungroup() -> coord

bcp_post_tbl %>% 
	left_join(coord, "house") -> post_coord_tbl

post_coord_tbl %>% select(house) %>% distinct() %>% 
	pull(house) -> house_ids

post_coord_tbl %>% 
	group_by(house) %>%
	mutate(max_prob = max(bcp_post_prob,na.rm = T)) %>% 
	ungroup() %>%
	select(house, max_prob, long_house, lat_house) %>% 
	distinct() %>% 
	mutate(flag = ifelse(max_prob > 0.5, "Yes", "No")) -> dist_probs

write_csv(dist_probs, "bcp_post_coords_tbl.csv")

pal <- colorFactor(c("navy", "red"), domain = c("Yes", "No"))
## plot leakage
leaflet(data = dist_probs) %>% addTiles() %>%
	addCircleMarkers(~long_house, ~lat_house,
																		popup = ~as.character(paste(long_house, lat_house)),
																		radius = ~ifelse(max_prob < 0.5, 6, 10),
																		color = ~pal(flag),stroke = FALSE, fillOpacity = 0.5)

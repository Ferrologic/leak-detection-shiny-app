library(geodist)

leak_tbl <- leak_tbl[, row_number := 1:nrow(leak_tbl)]

dist <- geodist::geodist(leak_tbl[, c("lat_house", "long_house")])

row_n <- leak_tbl[house == "house_leak168"]$row_number

row_n

house_dist <- data.table(dist = dist[row_n,], house = leak_tbl$house)[, house := order(house, dist)]

neighbours_row <- head(house_dist[order(rank(dist), house)], 10)

neighbours <- leak_tbl[row_number %in% unique(neighbours_row$house)]

consump_neighbours <-  all_obs[house %in% unique(neighbours$house)]

consump_neighbours

hchart(consump_neighbours, type = "line", hcaes(x = date, y = round(temp,0),
							group = house), title = "Cooling temperature amongst neighbours") %>%
	hc_title(text = "Cooling temperature") %>% 
	hc_yAxis(opposite = FALSE,
										title = list(text = "Cooling temperature"),
										labels = list(format = "{value}")) %>% 
	hc_tooltip(crosshairs = TRUE,
												pointFormat = 'Temperature: {point.y}</b><br>
												House: {point.house}')


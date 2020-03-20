
server <- shinyServer(function(input, output, session) {
  
  ## Load data and calculate distances 
  
  leak_tbl <- data.table::fread("bcp_post_coords_tbl.csv")
  
  leak_tbl <- leak_tbl[, id := 1:nrow(leak_tbl)]
  
  dist <- geodist::geodist(leak_tbl[, c("lat_house", "long_house")])
  
  ## Round temperature
  cols <- names(leak_tbl)[3:4]
  leak_tbl[,(cols) := round(.SD,5), .SDcols=cols]
  
  ## Read in all observations  
  
  all_obs <- data.table::fread("bcp_post_tbl.csv")
  all_obs <- all_obs[, date := as.Date(date)]
  
  ## Create shared dataframe for crosstalk
  
  sd <- SharedData$new(leak_tbl)
  
  output$leak_tbl <- DT::renderDT({
    
    # Use SharedData like a dataframe with Crosstalk-enabled widgets
    DT::datatable(sd, extensions="Scroller", style="bootstrap", class="compact", width="100%",
                  options=list(deferRender=TRUE, scrollY=300, scroller=TRUE))
    
  }, server = FALSE)
  
  output$leak_map <- renderLeaflet({
    pal <- leaflet::colorFactor(c("navy", "red"), domain = c("Yes", "No"))
    
    leaflet(sd) %>% addTiles() %>%
      addCircleMarkers(~long_house, ~lat_house,
                       popup = ~as.character(paste(house, "<br>Long:", long_house, "<br>Lat:", lat_house)),
                       radius = ~ifelse(max_prob < 0.5, 2, 5),
                       color = ~pal(flag),stroke = FALSE, fillOpacity = 1)
  }
  )
  
  
  output$alarms <- renderText({
    leak_tbl[max_prob > 0.9, list(n  = .N)][[1]]
  })
  
  output$proportion <- renderText({
    paste0(round((leak_tbl[max_prob > 0.9, list(n  = .N)][[1]]/ nrow(leak_tbl)),2)*100,"%")
  })
  
  output$choose_house <- renderUI({
    selectInput('house', 'Choose house', choices = unique(leak_tbl$house), multiple = TRUE)
  })
  
  output$run_analysis <- renderUI({
    actionButton("running", "Compare neighbours")
  })
  
  observeEvent(input$running,{
    row_n <- leak_tbl[house == input$house]$id
    
    house_dist <- data.table(dist = dist[row_n,],
                             house = leak_tbl$house)[, house := order(house, dist)]
    
    neighbours_row <- head(house_dist[order(rank(dist), house)], 10)
    
    neighbours <- leak_tbl[id %in% unique(neighbours_row$house)]
    
    consump_neighbours <-  all_obs[house %in% unique(neighbours$house)]
    
    output$comparison <- renderHighchart({
      hchart(consump_neighbours, type = "line", hcaes(x = date, y = round(temp,0),
                                                      group = house),
             title = glue::glue("Cooling temperature amongst neighbours for {input$house}")) %>%
        hc_title(text = glue::glue("Neighbours of {input$house}")) %>% 
        hc_yAxis(opposite = FALSE,
                 title = list(text = "Cooling temperature"),
                 labels = list(format = "{value}")) %>% 
        hc_tooltip(crosshairs = TRUE,
                   pointFormat = 'Temperature: {point.y}</b><br>
												House: {point.house}')
    })
    
    output$bcp_comparison <- renderHighchart({
      hchart(consump_neighbours, type = "line", hcaes(x = date, y = round(bcp_post_prob,2),
                                                      group = house), title = "Cooling temperature amongst neighbours") %>%
        hc_yAxis(opposite = FALSE,
                 title = list(text = ""),
                 labels = list(format = "{value}")) %>% 
        hc_tooltip(crosshairs = TRUE,
                   pointFormat = 'Temperature: {point.y}</b><br>
												House: {point.house}')
    })
    
    ### When house is chosen, render the UI  
    
    
  })
})



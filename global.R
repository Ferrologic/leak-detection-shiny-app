if (!require("pacman")) install.packages("pacman")
pacman::p_load(shiny,argonR,argonDash,shinyjs,
               shinyWidgets, shinycssloaders, 
               data.table, crosstalk, leaflet, 
               magrittr, highcharter)


library(plotly)

col_sm <- c("#f18616", "#a6569d", "#0698d6",
            "#5d7581", "#5ab031", "#4a4a4a")

pal <- leaflet::colorFactor(c("navy", "red"), domain = c("Yes", "No"))

ggplot2::theme(plot.title = ggplot2::element_text(# 
  size = 14,
  face = "bold", color = "#222222"),
  plot.subtitle = ggplot2::element_text(  size = 12,margin = ggplot2::margin(9, 0, 9, 0)),
  plot.caption = ggplot2::element_text( size = 10,  color = "#222222"), 
  legend.position = "top",
  # legend.text.align = 0,
  legend.background = ggplot2::element_blank(), 
  legend.title = ggplot2::element_blank(),
  legend.key = ggplot2::element_blank(), 
  legend.text = ggplot2::element_text( size = 9,  color = "#222222"),
  axis.title = ggplot2::element_text( size = 9, color = "#222222"), 
  axis.text = ggplot2::element_text( size = 9, color = "#222222"),
  axis.text.x = ggplot2::element_text(margin = ggplot2::margin(5, b = 10)),
  axis.ticks = ggplot2::element_blank(), 
  axis.line = ggplot2::element_blank(), 
  panel.grid.minor = ggplot2::element_blank(), 
  panel.grid.major.y = ggplot2::element_line(color = "#cbcbcb"), 
  panel.grid.major.x = ggplot2::element_blank(), 
  panel.background = ggplot2::element_blank(), 
  strip.background = ggplot2::element_rect(fill = "white"), 
  strip.text = ggplot2::element_text(size = 10, hjust = 0)) -> theme_tva


#conflict_prefer("select", "dplyr")
#conflict_prefer("layout", "plotly")
#conflict_prefer("filter", "dplyr")

# Feb 2020 ------------------------------
# UI interface for the shiny app

ui <- argonDash::argonDashPage(
  title = "",
  description = "",
  author = "SL",
  sidebar = argonDash::argonDashSidebar(
    vertical = T,
    skin = 'dark',
    background = "#4a4a4a",
    size = "lg",
    side = "left",
    id = "sidebar",
    gradient = T,
    brand_url = "",
    brand_logo = "particle.png",
    argonDash::argonSidebarMenu(
      title = "Menu",
      argonDash::argonSidebarItem(
        tabName = 'Bmet',
        #  icon = 'atom',
        icon_color = '#4a4a4a',
        'Identify leakages with changepoint analysis'
      ),
      br()
    )
  ),
  body = argonDash::argonDashBody(
    shinyjs::useShinyjs(), # Include shinyjs in the UI
    #  tags$head(
    #    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    #  ),
    tags$head(
      tags$style(HTML("
      
@import url('https://fonts.googleapis.com/css?family=Montserrat:400,700%27');

.nav-pills .nav-link.active, .nav-pills .show>.nav-link  {
    color: #fff;
    background-color: #4a4a4a;
}
###
.navbar-vertical .navbar-brand-img, .navbar-vertical .navbar-brand>img {
    max-width: 100%;
    max-height: 100%;
}

.navbar-vertical.navbar-expand-lg .navbar-brand-img {
    max-height: 14.5rem;
}

.navbar-brand-img {
 width: 100px;
 height: 100px;		
}
###
.nav-pills .nav-link {
  color:#4a4a4a;

}

.nav-pills:hover .nav-link:hover {
  color: #4a4a4a;
  font-weight: bold;
}

.nav-pills .nav-link.active:hover, .nav-pills .show>.nav-link:hover  {
    color: #fff;
    background-color: #4a4a4a;

}

.btn-default {
    background-color: transparent;
    color: #4a4a4a;
    border:2px solid #4a4a4a
}

.text-success {
    color: #fff!important;
}

.text-danger {
    color: #fff!important;
}


.btn-default.hover, .btn-default:active, .btn-default:hover {
	background-color: #4a4a4a;
	color: #fff;
}


.navbar-vertical.navbar-expand-md .navbar-brand{
  padding-bottom: 0rem;
}

body {
  font-family: 'Montserrat', sans-serif; color: #4a4a4a
}

.icon {
    color: #4a4a4a !important;
}

.text-primary {
    color: #4a4a4a !important;
    font-size: 1.2em !important;
}

.icon-shape-primary {
    background-color: white !important;
}

.h1, .h2, .h3, .h4, .h5, .h6, h1, h2, h3, h4, h5, h6 {
    font-family: inherit;
    font-weight: 600;
    line-height: 1.5;
    margin-bottom: .5rem;
        color: #4a4a4a !important;
        text-transform: uppercase!important;
}

.h5, h5 {
    font-size: .8125rem;
            color: #8c8c8c !important;

}

.h4 {
    color: #4a4a4a !important;
    font-size: 1.3em !important;
}

.h3 {
    color: #4a4a4a !important;
    font-size: 1.3em !important;
}

.h2 {
    color: #4a4a4a !important;
    font-size: 1.3em !important;
}

.h5 {
    color: #4a4a4a !important;
    font-size: 1.3em !important;
}

.h6 {
    color: #4a4a4a !important;
    font-size: 1.3em !important;
}

.h7 {
    color: #4a4a4a !important;
    font-size: 1.3em !important;
}

.card-title {
    color: #4a4a4a !important;
    font-size: 0.8em !important;
}

table.dataTable.no-footer {
    border-bottom: 0px solid #111 !important;
}

table.dataTable thead th, table.dataTable thead td {
    border-bottom: 0px solid #111 !important; 
}

.dataTables_wrapper.no-footer .dataTables_scrollBody {
    border-bottom: 0px solid #111 !important;
}

.bg-info {
    background-color: #4a4a4a !important;
}

.card-body {
    padding: 0rem 1.5rem;
    flex: 1 1 auto;
}

div.selectize-input div.item {
  color: #fff !important;
  background-color: #4a4a4a !important;
}

    "))
    ),
    argonDash::argonTabItems(
      argonDash::argonTabItem(
        tabName = "Bmet",
        argonR::argonRow(
          argonTabSet(
            id = "tab-1",
            card_wrapper = TRUE,
            horizontal = TRUE,
            circle = FALSE,
            size = "sm",
            width = 12,
            # iconList = list("chart-bar-32","user-08"),
            argonTab(
              tabName = "Possible leaks",
              active = T,
              argonR::argonRow(
                #,
                #argonRow(
                #  argonCard(width = 2, 
                #                   title = h5("Possible leaks"),
                #                   # icon = "chart-bar-32",
                #                   h2(textOutput("alarms"))
                #),
                #argonCard(width = 2, 
                #          title = h5("%possible leaks"),
                #           # icon = "circle-08",
                #          h2(textOutput("proportion"))
                #),
                argonCard(
                  width = 12,
                  height = 10,
                  title = "All houses",
                  #icon = "chart-pie-35",
                  #addSpinner(plotlyOutput("ga_plot", height = "350px"), spin = "circle", color = "#000000")
                  DT::DTOutput("leak_tbl")
                ),
                argonCard(
                  width = 12,
                  height = 12,
                  title = "Possible leaks",
                  #icon = "chart-pie-35",
                  #addSpinner(plotlyOutput("ga_plot", height = "350px"), spin = "circle", color = "#000000")
                  leaflet::leafletOutput("leak_map")
                ),
                argonCard(
                  title = "Compare neighbours",
                  width = 6,
                  uiOutput("choose_house") ,
                  uiOutput("run_analysis")
                  ),
                argonCard(
                  title = "Comparison neighbours",
                  width = 12,
                  highcharter::highchartOutput("comparison")
                  ),
                argonCard(
                  title = "Comparison probability of leakage",
                  width = 12,
                  height = 2,
                  highcharter::highchartOutput("bcp_comparison")
                )
              )
            )
          )
        )
      )
    ),
    argonDash::argonTabItem(
      tabName = "about",
      argonR::argonUser(
        title = 'About',
        url = 'https://www.ferrologic.se',
        style = "text-align:left",
        br()
      )
    )
  )
)

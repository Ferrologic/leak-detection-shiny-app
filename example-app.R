library(shiny)
library(crosstalk)
library(d3scatter)
library(DT)

ui <- fluidPage(
	fluidRow(
		column(6, d3scatterOutput("scatter1")),
		column(6, DTOutput("scatter2"))
	)
)

server <- function(input, output, session) {
	shared_iris <- SharedData$new(iris)
	
	output$scatter1 <- renderD3scatter({
		d3scatter(shared_iris, ~Petal.Length, ~Petal.Width, ~Species, width = "100%")
	})
	
	output$scatter2 <- renderDT({
		datatable(shared_iris, extensions="Scroller", style="bootstrap", class="compact", width="100%",
												options=list(deferRender=TRUE, scrollY=300, scroller=TRUE))
	}, server = FALSE)
}

shinyApp(ui, server)


library(shiny)
library(DT)
library(ggplot2)

ui <- basicPage(
	plotOutput("plot1", click = "plot_click"),
	dataTableOutput("table1"),
	verbatimTextOutput("info")
)

server <- function(input, output) {
	output$table1 <- DT::renderDataTable(mtcars)
	#figure out a way to reactively select points to point into output$plot1
	output$plot1 <- renderPlot({
		s = input$table1_rows_selected
		mtcars <- mtcars[ s,]
		ggplot(mtcars, aes(mtcars$wt, mtcars$mpg)) + geom_point()
	})
	
	output$info <- renderPrint({
		# With base graphics, need to tell it what the x and y variables are.
		nearPoints(mtcars, input$plot_click, xvar = "wt", yvar = "mpg")
		# nearPoints() also works with hover and dblclick events
	})
}

shinyApp(ui, server)
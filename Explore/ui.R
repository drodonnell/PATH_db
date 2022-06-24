library(shinydashboard)
library(shinyjs)
library(waiter)
library(plotly)
library(shinycssloaders)
library(googleway)

ui <- dashboardPage(
	dashboardHeader(title = "FishDB Database exploration tool", titleWidth = 500,
									tags$li(actionLink("openModal", label = "", icon = icon("info-circle")),
													class = "dropdown")),
	dashboardSidebar(width=310,
	                 disable = F,
									 sidebarMenu(id = "sidebar",
									 						menuItem("Explore", tabName = "main", icon = icon("dashboard")),
															selectInput("select_db", "Database", choices = NULL, multiple=F, width=310),
															selectInput("select_schema", "Schema", choices = NULL, multiple=F, width=310),
															selectInput("select_tables", "Table", choices = NULL, multiple=F, width=310),
															selectInput("select_columns", "Columns", choices = NULL, multiple=T, width=310),
															selectInput("select_sort", "Sort by", choices = NULL, multiple=F, width=310),
															selectInput("select_dir", "Order", choices = c("ASC", "DESC"), multiple=F, width=310),
															numericInput("select_limit", "Max Rows", min = 0, value = 100, step = 1, width=310),
															tags$hr(),
															tags$div(class = 'container',
																downloadButton("btn_download", "Download CSV", class = 'btn btn-primary')
															)
									 )
	),
	dashboardBody(
		useShinyjs(),
		use_waiter(spinners = 6),
		waiter_show_on_load(html = spin_loaders(8, color = '#005fae', style="width: 200px;
    # height:200px;"), color = transparent(.5)),
		tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css")),

		tabItem(tabName = "main",
							fluidRow(
								column(12,
									tabBox(title = "Table View", id = "tabs", width = 12, side = "right",
									 #tabPanel("Databases",
										#htmlOutput("databases_div"),
								 		#),
									 #tabPanel("Tables",
										#htmlOutput("tables_div"),
								 		#),
									 #tabPanel("Columns",
										#htmlOutput("columns_div"),
								 		#),
									tabPanel("Results",
										htmlOutput("results_div")
									),
									tabPanel("Map",
										google_mapOutput("map_canvas")
									),
									tabPanel("Datasets",
									   htmlOutput("datasets_div")
									)
								 ),
								)
							)
						)
	)
)

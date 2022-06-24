
source("../shared/db.R")
source("../shared/fetch.R")

library(DT)
library(googleway)

render_map <- function() {
	renderGoogle_map({
		google_map(key = Sys.getenv("MAPS_API_KEY"), location = c(38.5, -121.5),
							 zoom = 8, search_box = TRUE, geolocation = TRUE,
							 width = '100%', height = '100%')
	 })
}

update_map <- function(map_id, marker_data) {

	if("Latitude" %in% colnames(marker_data) & "Longitude" %in% colnames(marker_data)) {
		data <- marker_data %>%
						mutate(lat = Latitude, lon = Longitude) %>%
						select(-Latitude, -Longitude) %>%
						distinct(lat, lon) %>%
						as.data.frame()

			google_map_update(map_id = map_id) %>%
				clear_markers() %>%
				add_markers(data = data, draggable = FALSE, update_map_view = FALSE)
		}
}


server <- function(input, output, session) {

	options = list(autoWidth=TRUE, pageLength=50, scrollX="100%",scrollY="100%")

	getDBInfo <- reactive({
			getDatabases()
	})
	
	getSchemaInfo <- reactive({
	  getDbSchemas(req(input$select_db))
	})

	getTableInfo <- reactive({
		getDbTables(req(input$select_db), req(input$select_schema))
	})

	getColumnsInfo <- reactive({
		getTableCols(req(input$select_db), req(input$select_schema), req(input$select_tables))
	})

	getResults <- reactive({
		getDataFromDB(req(input$select_db), req(input$select_schema), req(input$select_tables),
								 req(input$select_columns), req(input$select_limit), input$select_sort, input $select_dir)
	})

	updateSelectInput(session, "select_db", choices = getDatabases())
	output$map_canvas <- render_map()

	observe({
		update_map("map_canvas", getResults() )
	})

	observeEvent(input$openModal, {
		showModal(
			modalDialog(title = "About...",
				HTML("About")
			)
		)
	})

	#output$databases_div <- renderUI({
	#	dataTableOutput("databases_table")
	#})

	#output$databases_table <- renderDT( getDBInfo(), options = options, rownames = F)

	waiter_hide()

	observeEvent(input$select_db, {
		updateSelectInput(session, "select_schema", choices = getSchemaInfo()$table_schema, selected = F)
	})
	
	observeEvent(input$select_schema, {
		updateSelectInput(session, "select_tables", choices = getTableInfo()$table_name, selected = F)
			#output$tables_div <- renderUI({
		  # dataTableOutput("tables_table")
			#})

			#output$tables_table <- renderDT( getTableInfo(), options = options, rownames = F)
			#updateTabItems(session, "tabs", selected = "Tables")
	})

	observeEvent(input$select_tables, {
		table_cols <- getColumnsInfo()$column_name
		updateSelectInput(session, "select_columns", choices = table_cols, selected = table_cols)

		#output$columns_div <- renderUI({
			#dataTableOutput("columns_table")
		#})

		#output$columns_table <- renderDT( getColumnsInfo(), options = options, rownames = F)

		waiter_show(html = spin_loaders(8, color = '#005fae', style="width: 200px; height:200px;"), color = transparent(.5))

		output$results_div <- renderUI({
			dataTableOutput("results_table")
		})

		output$results_table <- renderDT( getResults(), options = options, rownames = F)

		waiter_hide()

		updateTabItems(session, "tabs", selected = "Results")
		update_map("map_canvas", getResults() )
	})
	
	observeEvent(input$select_columns, {
	  updateSelectInput(session, "select_sort", choices = colnames(getResults()))
	})


	output$btn_download <- downloadHandler(

		filename = function() { paste0("fishdb-", input$select_db, "-", input$select_schema, "-", input$select_tables, "-", Sys.Date(), ".csv") },
		content = function(file) {
			waiter_show(html = spin_loaders(8, color = '#005fae', style="width: 200px; height:200px;"), color = transparent(.5))
			write.csv(getResults(), file, row.names = FALSE)
			waiter_hide()
		}

	)
}





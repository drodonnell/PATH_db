library(dplyr)
library(dbplyr)
library(lubridate)
source("../shared/db.R")

getDatabases <- function() {
	return(data.frame(db_name = c("JSATS_Acoustic_Biotelemetry_Database", "69kHz_Acoustic_Biotelemetry_Database")))
}

getDbSchemas <- function(db = "JSATS_Acoustic_Biotelemetry_Database") {
  con <- dbGetPGCon(db)
  results <- dbGetQuery(con, paste0("SELECT table_catalog, table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema')"))
  dbDisconnect(con)
  results
}

getDbTables <- function(db = "JSATS_Acoustic_Biotelemetry_Database", schema = "public") {
	con <- dbGetPGCon(db)
	results <- dbGetQuery(con, DBI::sqlInterpolate(con, "SELECT table_catalog, table_schema, table_name FROM information_schema.tables WHERE table_schema = ?schema", schema = schema))
	dbDisconnect(con)
	results
}

getTableCols <- function(db, schema, table) {
	con <- dbGetPGCon(db)
	cols <- dbGetQuery(con, DBI::sqlInterpolate(con,"SELECT table_catalog, table_schema, table_name, column_name FROM information_schema.columns WHERE table_schema = ?schema AND table_name = ?table", schema = schema, table = table))
	dbDisconnect(con)
	return(cols)
}

getDataFromDB <- function(db, schema, table, columns, limit = 1000, sort_cols = NULL, sort_dir = "ASC") {
	con <- dbGetPGCon(db)

	data <- tbl(con, in_schema(schema, table)) %>%
		select(all_of(columns)) 
	
	if(!is.null(sort_cols) & sort_cols != '') {
	  
	  if(sort_dir == "ASC") {
  	  data <- data %>%
	      arrange(!!sym(sort_cols))
	  } 
	  
	  if(sort_dir == "DESC") {
	    data <- data %>%
	      arrange(desc(!!sym(sort_cols)))
	  }
	}
	
	data <- data %>%
	    head(limit)
	
	cat(db, schema, table, columns, sort_cols, sort_dir, "\n")
	data %>% show_query
	
	return(data %>% as.data.frame())
}

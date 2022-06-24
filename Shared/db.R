library(odbc)

dbGetMSCon <- function(database = "") {

	readRenviron('../.Renviron')

	if(database != "") {

		return(
			dbConnect(odbc(),
			Driver = "freetds",
			Server = Sys.getenv('ms_dbhost'),
			Database = database,
			UID = Sys.getenv('ms_dbuser'),
			trusted_connection = 'no',
			PWD = Sys.getenv('ms_dbpwd'),
			Port = 1433)
		)
	}

	return(
		dbConnect(odbc(),
		Driver = "freetds",
		Server = Sys.getenv('ms_dbhost'),
		UID = Sys.getenv('ms_dbuser'),
		trusted_connection = 'no',
		PWD = Sys.getenv('ms_dbpwd'),
		Port = 1433)
	)
}

dbGetPGCon <- function(database = "") {
	readRenviron("../.Renviron")
	if(database != "") {
		return(
			con <- DBI::dbConnect(
			RPostgres::Postgres(),
			host = Sys.getenv("pg_dbhost"),
			user = Sys.getenv("pg_dbuser"),
			password = Sys.getenv("pg_dbpwd"),
			dbname = database
			)

		)
	}

	return(
			con <- DBI::dbConnect(
			RPostgres::Postgres(),
			host = Sys.getenv("pg_dbhost"),
			user = Sys.getenv("pg_dbuser"),
			password = Sys.getenv("pg_dbpwd"),
			)
	)

}



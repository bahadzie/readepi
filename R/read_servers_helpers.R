#' Establish connection to the server
#'
#' @param dbms the database management system type
#' @param driver_name the driver name
#' @param host the host server name
#' @param database_name the database name
#' @param user the user name
#' @param password the user's password
#' @param port the server port ID
#'
#' @return the connection object
#' @export
#'
#' @examples
#' con <- connect_to_server(
#'  dbms = "MySQL",
#'  driver_name = "",
#'  host = "mysql-rfam-public.ebi.ac.uk",
#'  database_name = "Rfam",
#'  user = "rfamro",
#'  password = "",
#'  port = 4497
#' )
connect_to_server <- function(dbms, driver_name, host, database_name,
                              user, password, port) {
  checkmate::assert_character(dbms, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(driver_name, len = 1, null.ok = FALSE,
                              any.missing = FALSE)
  checkmate::assert_character(host, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(database_name, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(user, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(password, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_number(port, lower = 1)
  con <- switch(dbms,
                "SQLServer" = pool::dbPool(odbc::odbc(),
                                             driver = driver_name,
                                             server = host,
                                             database = database_name,
                                             uid = user, pwd = password,
                                             port = as.numeric(port)
                ),
                "PostgreSQL" = pool::dbPool(odbc::odbc(),
                                              driver = driver_name,
                                              host = host,
                                              database = database_name,
                                              uid = user, pwd = password,
                                              port = as.numeric(port)
                ),
                "MySQL" = pool::dbPool(drv = RMySQL::MySQL(),
                                       dbname = database_name,
                                       username = user, password = password,
                                       host = host, port = as.numeric(port),
                                       driver = driver_name,
                                       maxSize = 50
                )
  )
  con
}


#' Detect table names from an SQL query
#'
#' @param query the SQL query
#' @param tables the list of all tables from the database
#'
#' @return the table name of interest
#' @export
#'
#' @examples
#' table_name = identify_table_name(
#'  query = "select * from author",
#'  tables = c("family_author", "author", "test")
#' )
#'
identify_table_name <- function(query, tables) {
  checkmate::assert_character(query, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_vector(tables, any.missing = FALSE, min.len = 1,
                           null.ok = FALSE, unique = TRUE)
  table_name <- NULL
  query <- unlist(strsplit(query, " ", fixed = TRUE))
  table_name <- query[which(query %in% tables)]
  table_name <- ifelse(length(table_name) == 1, table_name,
                       glue::glue_collapse(table_name, sep = "_"))
  table_name
}

#' Fetch data from server using an SQL query
#'
#' @param source the SQL query
#' @param dbms the database management system type
#' @param tables the list of tables from the database
#' @param driver_name the driver name
#' @param host the host server name
#' @param database_name the database name
#' @param user the user name
#' @param password the user's password
#' @param port the server port ID
#'
#' @return a list with the data fetched from the tables of interest
#' @export
#'
#' @examples
#' result <- fetch_data_from_query(
#'  source = "select author_id, name, last_name from author",
#'  dbms = "MySQL",
#'  tables = c("family_author", "author"),
#'  driver_name = "",
#'  host = "mysql-rfam-public.ebi.ac.uk",
#'  database_name = "Rfam",
#'  user = "rfamro",
#'  password = "",
#'  port = 4497
#' )
#'
fetch_data_from_query <- function(source, dbms, tables,
                                 driver_name, host, database_name,
                                 user, password, port) {
  checkmate::assert_vector(source,
                           any.missing = FALSE, min.len = 1,
                           null.ok = FALSE, unique = TRUE
  )
  checkmate::assert_character(dbms, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_vector(tables,
                           any.missing = FALSE, min.len = 1,
                           null.ok = FALSE, unique = TRUE)
  checkmate::assert_character(driver_name, len = 1, null.ok = FALSE,
                              any.missing = FALSE)
  checkmate::assert_character(host, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(database_name, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(user, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(password, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_number(port, lower = 1)

  pool <- connect_to_server(dbms, driver_name, host, database_name,
                           user, password, port)
  result <- list()
  for (query in source) {
    table <- identify_table_name(query, tables)
    stopifnot("Could not detect table name from the query" = !is.null(table))
    result[[table]] <- DBI::dbGetQuery(pool, source)
  }

  pool::poolClose(pool)
  result
}


#' Subset data read from servers
#'
#' @param table_names the name of the tables where the data was fetched from
#' @param dbms the database management system type
#' @param id_col_name the column names that unique identify the records in the
#' tables
#' @param fields a vector of strings where each string is a comma-separated list
#' of column names.
#' @param records a vector or a comma-separated string of subset of subject IDs.
#' @param id_position a vector of the column positions of the variable that
#' unique identifies the subjects in each table
#' @param driver_name the driver name
#' @param host host server name
#' @param database_name the database name
#' @param user the user name
#' @param password the user's password
#' @param port the server port ID
#'
#' @return a subset of the data in the specified tables
#' @export
#' @examples
#' result = sql_select_data(
#'  table_names = "author",
#'  dbms = "MySQL",
#'  id_col_name = "author_id",
#'  fields = c("author_id", "name"),
#'  records = NULL,
#'  id_position = NULL,
#'  driver_name = "",
#'  host = "mysql-rfam-public.ebi.ac.uk",
#'  database_name = "Rfam",
#'  user = "rfamro",
#'  password = "",
#'  port = 4497
#' )
#'
sql_select_data <- function(table_names, dbms, id_col_name,
                            fields, records, id_position,
                            driver_name, host, database_name,
                            user, password, port) {
  checkmate::assert_number(port, lower = 1)
  checkmate::assert_character(password, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(user, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(host, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(driver_name, len = 1, null.ok = FALSE,
                              any.missing = FALSE)
  checkmate::assert_vector(table_names,
                           any.missing = FALSE, min.len = 1,
                           null.ok = FALSE, unique = FALSE
  )
  checkmate::assert_character(dbms, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_vector(id_col_name,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = FALSE
  )
  checkmate::assert_vector(records,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_vector(fields,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_vector(id_position,
                           any.missing = FALSE, min.len = 0,
                           null.ok = TRUE, unique = FALSE
  )
  checkmate::assert_character(database_name, any.missing = FALSE, len = 1,
                              null.ok = FALSE)

  # con <- connect_to_server(dbms, driver_name, host, database_name,
  #                          user, password, port)
  result <- list()
  j <- 1
  for (table in table_names) {
    R.utils::cat("\nFetching data from", table)

    # select records from table
    if (all(is.null(records) & is.null(fields))) {
      result[[table]] <- sql_select_entire_dataset(table, dbms, driver_name,
                                                   host, database_name, user,
                                                   password, port)
    } else if (!is.null(records) && is.null(fields)) {
      record <- ifelse(all(grepl(",", records, fixed = TRUE) == TRUE &
                             length(records) > 1),
                       records[j], records)
      result[[table]] <- sql_select_records_only(table, record, id_col_name,
                                                 id_position, dbms, driver_name,
                                                 host, database_name, user,
                                                 password, port)

    } else if (!is.null(fields) && is.null(records)) {
      field <- ifelse(all(grepl(",", fields, fixed = TRUE) == TRUE &
                            length(fields) > 1),
                      fields[j], fields)
      result[[table]] <- sql_select_fields_only(table, field, dbms, driver_name,
                                                host, database_name, user,
                                                password, port)
    } else {
      record <- ifelse(all(grepl(",", records, fixed = TRUE) == TRUE &
                             length(records) > 1),
                       records[j], records)
      field <- ifelse(all(grepl(",", fields, fixed = TRUE) == TRUE &
                            length(fields) > 1),
                      fields[j], fields)
      id_column_name <- get_id_column_name(id_col_name, j, id_position)[[1]]
      id_pos <- get_id_column_name(id_col_name, j, id_position)[[2]]
      result[[table]] <- sql_select_records_and_fields(table, record,
                                                       id_column_name, field,
                                                       id_pos, dbms,
                                                       driver_name, host,
                                                       database_name, user,
                                                       password, port)
    }

    j <- j + 1
  }
  result
}

#' get the id column name
#'
#' @param id_col_name the id column name
#' @param j the index
#' @param id_position the id position
#'
get_id_column_name <- function(id_col_name, j, id_position) {
  checkmate::assert_vector(id_col_name,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = FALSE
  )
  checkmate::assert_numeric(j, lower = 1, any.missing = FALSE,
                            len = 1, null.ok = FALSE)
  checkmate::assert_vector(id_position,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = FALSE
  )
  id_column_name <- id_pos <- NULL
  if (!is.null(id_col_name)) {
    id_col_name <- gsub(" ", "", id_col_name, fixed = TRUE)
    id_col_name <- unlist(strsplit(id_col_name, ",", fixed = TRUE))
    id_column_name <- ifelse(!is.na(id_col_name[j]), id_col_name[j], NULL)
  }

  if (!is.null(id_position)) {
    id_position <- gsub(" ", "", id_position, fixed = TRUE)
    id_position <- unlist(strsplit(id_position, ",", fixed = TRUE))
    id_pos <- ifelse(!is.na(id_position[j]), id_position[j], NULL)
  }

  list(
    id_column_name,
    id_pos
  )
}

#' Fetch entire dataset in a table
#'
#' @param table the table name
#' @param dbms the database management system type
#' @param driver_name the driver name
#' @param host host server name
#' @param database_name the database name
#' @param user the user name
#' @param password the user's password
#' @param port the server port ID
#'
#' @return a data frame with the entire dataset that is contained in the table
#' @export
#'
#' @examples
#' result <- sql_select_entire_dataset(
#'  table = "author",
#'  dbms = "MySQL",
#'  driver_name = "",
#'  host = "mysql-rfam-public.ebi.ac.uk",
#'  database_name = "Rfam",
#'  user = "rfamro",
#'  password = "",
#'  port = 4497
#' )
#'
sql_select_entire_dataset <- function(table, dbms, driver_name, host,
                                      database_name, user, password, port) {
  checkmate::assert_character(table, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(dbms, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(driver_name, len = 1, null.ok = FALSE,
                              any.missing = FALSE)
  checkmate::assert_character(host, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(database_name, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(user, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(password, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_number(port, lower = 1)

  con <- connect_to_server(dbms, driver_name, host, database_name,
                           user, password, port)
  query <- paste0("select * from ", table)
  res <- DBI::dbGetQuery(con, query)
  pool::poolClose(con)
  res
}

#' Select specified records and fields from a table
#'
#' @param table the table name
#' @param record a vector or a comma-separated string of subset of subject IDs.
#' @param dbms the database management system type
#' @param driver_name the driver name
#' @param host host server name
#' @param database_name the database name
#' @param user the user name
#' @param password the user's password
#' @param port the server port ID
#' @param id_column_name the column names that unique identify the records in
#' the tables
#' @param field a vector of strings where each string is a comma-separated list
#' of column names.
#' @param dbms the database management system type
#' @param id_pos a vector of the column positions of the variable that
#' unique identifies the subjects in each table
#'
#' @return a data frame with the specified columns and records
#' @export
#'
#' @examples
#' result <- sql_select_records_and_fields(
#'  table = "author",
#'  record = c("1", "20", "50"),
#'  id_column_name = "author_id",
#'  field = c("author_id", "last_name"),
#'  id_pos = NULL,
#'  dbms = "MySQL",
#'  driver_name = "",
#'  host = "mysql-rfam-public.ebi.ac.uk",
#'  database_name = "Rfam",
#'  user = "rfamro",
#'  password = "",
#'  port = 4497
#' )
#'
sql_select_records_and_fields <- function(table, record, id_column_name, field,
                                          id_pos, dbms, driver_name, host,
                                          database_name, user, password, port) {
  checkmate::assert_character(dbms, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(driver_name, len = 1, null.ok = FALSE,
                              any.missing = FALSE)
  checkmate::assert_character(host, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(database_name, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(user, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(password, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_number(port, lower = 1)
  checkmate::assert_character(id_column_name,
                           any.missing = FALSE,
                           null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_character(id_pos,
                              any.missing = FALSE,
                              null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_character(table, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_vector(record,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_vector(field,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )

  con <- connect_to_server(dbms, driver_name, host, database_name,
                           user, password, port)
  res <- sql_select_records_only(table, record, id_column_name, id_pos, dbms,
                                 driver_name, host, database_name, user,
                                 password, port)
  if (is.character(field)) {
    field <- as.character(lapply(field, function(x) {
      gsub(" ", "", x, fixed = TRUE)
    }))
    field <- unlist(strsplit(field, ",", fixed = TRUE))
  }
  res <- res %>% dplyr::select(dplyr::all_of(field))
  pool::poolClose(con)
  res
}


#' Visualize the first 5 rows of the data from a table
#'
#' @param credentials_file the path to the file with the user-specific
#' credential details for the projects of interest
#' @param source the table name
#' @param project_id the name of the target database
#' @param driver_name the name of the MS driver
#'
#' @return return the first 5 rows of the table if display=TRUE
#' @export
#'
#' @examples
#' visualise_table(
#'  credentials_file <- system.file("extdata", "test.ini", package = "readepi"),
#'   source = "author",
#'   project_id = "Rfam",
#'   driver_name = ""
#' )
#'
visualise_table <- function(credentials_file, source, project_id,
                            driver_name) {
  checkmate::assert_character(source, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(credentials_file, null.ok = FALSE, len = 1)
  checkmate::assert_file_exists(credentials_file)
  checkmate::assert_character(project_id, null.ok = FALSE, len = 1)
  checkmate::assert_character(driver_name, null.ok = FALSE, len = 1)

  credentials <- read_credentials(credentials_file, project_id)
  con <- connect_to_server(credentials$dbms, driver_name, credentials$host,
                           project_id, credentials$user, credentials$pwd,
                           credentials$port)
  query <- ifelse(credentials$dbms == "MySQL",
                  paste0("select * from ", source, " limit 5"),
                  paste0("select top 5 * from ", source))
  res <- DBI::dbGetQuery(con, query)
  pool::poolClose(con)
  print(res)
}


#' Select specified records from a table
#'
#' @param table the table name
#' @param record a vector or a comma-separated string of subset of subject IDs.
#' @param id_column_name the column names that unique identify the records in
#' the tables
#' @param id_pos a vector of the column positions of the variable that
#' unique identifies the subjects in each table
#' @param dbms the database management system type
#' @param driver_name the driver name
#' @param host host server name
#' @param database_name the database name
#' @param user the user name
#' @param password the user's password
#' @param port the server port ID
#'
#' @return a data frame with the records of interest
#' @export
#'
#' @examples
#' result <- sql_select_records_only(
#'  table = "author",
#'  record = c("1", "20", "50"),
#'  id_column_name = NULL,
#'  id_pos = 1,
#'  dbms = "MySQL",
#'  driver_name = "",
#'  host = "mysql-rfam-public.ebi.ac.uk",
#'  database_name = "Rfam",
#'  user = "rfamro",
#'  password = "",
#'  port = 4497
#' )
sql_select_records_only <- function(table, record, id_column_name, id_pos,
                                    dbms, driver_name, host, database_name,
                                    user, password, port) {
  checkmate::assert_vector(id_pos,
                           any.missing = FALSE, min.len = 0,
                           null.ok = TRUE, unique = FALSE
  )
  checkmate::assert_vector(id_column_name,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = FALSE
  )
  checkmate::assert_character(table, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_vector(record,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_character(dbms, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(driver_name, len = 1, null.ok = FALSE,
                              any.missing = FALSE)
  checkmate::assert_character(host, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(database_name, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(user, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(password, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_number(port, lower = 1)

  con <- connect_to_server(dbms, driver_name, host, database_name,
                           user, password, port)
  query <- ifelse(dbms == "MySQL",
                  paste0("select * from ", table, " limit 5"),
                  paste0("select top 5 * from ", table))
  first_5_rows <- DBI::dbGetQuery(con, query)
  id_col_name <- ifelse(!is.null(id_column_name),
                       id_column_name,
                       names(first_5_rows)[id_pos])
  stopifnot("Missing or NULL value found in record argument" = (anyNA(record) ||
                                                          !any(is.null(record)))
  )

  if (is.vector(record)) {
    record <- glue::glue_collapse(record, sep = ", ")
  }
  record <- as.character(lapply(record, function(x) {
    gsub(" ", "", x, fixed = TRUE)
  }))
  record <- gsub(",", "','", record, fixed = TRUE)
  query <- paste0("select * from ", table,
                  " where (", id_col_name, " in ('", record, "'))")
  res <- DBI::dbGetQuery(con, query)
  pool::poolClose(con)
  res
}


#' Select specified fields from a table
#'
#' @param table the table name
#' @param field a vector of column names of interest
#' @param dbms the database management system type
#' @param driver_name the driver name
#' @param host host server name
#' @param database_name the database name
#' @param user the user name
#' @param password the user's password
#' @param port the server port ID
#'
#' @return a data frame with the specified fields
#' @export
#'
#' @examples
#' result <- sql_select_fields_only(
#'  table = "author",
#'  field = c("author_id", "name", "last_name"),
#'  dbms = "MySQL",
#'  driver_name = "",
#'  host = "mysql-rfam-public.ebi.ac.uk",
#'  database_name = "Rfam",
#'  user = "rfamro",
#'  password = "",
#'  port = 4497
#')
#'
sql_select_fields_only <- function(table, field, dbms, driver_name, host,
                                   database_name, user, password, port) {
  checkmate::assert_character(table, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_vector(field,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_character(dbms, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(driver_name, len = 1, null.ok = FALSE,
                              any.missing = FALSE)
  checkmate::assert_character(host, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(database_name, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(user, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(password, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_number(port, lower = 1)

  stopifnot("Missing or NULL value found in record argument" = (anyNA(field) ||
                                                          !any(is.null(field)))
  )
  con <- connect_to_server(dbms, driver_name, host, database_name,
                           user, password, port)
  if (is.vector(field)) {
    field <- glue::glue_collapse(field, sep = ", ")
  }
  field <- as.character(lapply(field, function(x) {
    gsub(" ", "", x, fixed = TRUE)
  }))
  field <- as.character(lapply(field, function(x) {
    gsub(",", ", ", x, fixed = TRUE)
  }))
  query <- paste0("select ", field, " from ", table)
  res <- DBI::dbGetQuery(con, query)
  pool::poolClose(con)
  res
}

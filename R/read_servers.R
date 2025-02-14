#' Read data from relational databases hosted by a MS SQL server.
#' @description For a user with read access to a Microsoft SQL server,
#' this function allows data import from the database into R. It required the
#' installation
#' of the appropriate MS driver that is compatible with the SQL server version
#' hosting the
#' database.
#' @param user the user name
#' @param password the user password
#' @param host the name of the host server
#' @param port the port ID
#' @param database_name the name of the database that contains the table from
#' which the data should be pulled
#' @param source and SQL query or a vector of table names from
#' the project or database. When this is not specified, the function will
#' extract data from all tables in the database.
#' @param driver_name the name of the MS driver. use `odbc::odbcListDrivers()`
#' to display the list of installed drivers
#' @param records a vector or a comma-separated string of subset of subject IDs.
#' When specified, only the records that correspond to these subjects will be
#' imported.
#' @param fields a vector of strings where each string is a comma-separated list
#' of column names. The element of this vector should be a list of column names
#' from the first table specified in the `table_names` argument and so on...
#' @param id_position a vector of the column positions of the variable that
#' unique identifies the subjects in each table. When the column name with the
#' subject IDs is known, use the `id_col_name` argument instead. default is.
#' default is 1.
#' @param id_col_name the column name with the subject IDs
#' @param dbms the SQL server type
#' @returns a list of data frames
#' @examples
#' \dontrun{
#' data <- sql_server_read_data(
#'   user = "rfamro",
#'   password = "",
#'   host = "mysql-rfam-public.ebi.ac.uk",
#'   port = 4497,
#'   database_name = "Rfam",
#'   source = "author",
#'   driver_name = "",
#'   dbms = "MySQL"
#' )
#' }
#' @export
#' @importFrom magrittr %>%
sql_server_read_data <- function(user, password, host, port = 1433,
                                 database_name, driver_name,
                                 source = NULL, records = NULL,
                                 fields = NULL, id_position = NULL,
                                 id_col_name = NULL, dbms) {
  # check the input arguments
  checkmate::assert_vector(id_position,
                           any.missing = FALSE, min.len = 0,
                           null.ok = TRUE, unique = FALSE
  )
  checkmate::assert_vector(id_col_name,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = FALSE
  )
  checkmate::assert_number(port, lower = 1)
  checkmate::assert_character(user, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(dbms, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(password, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(host, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(database_name, any.missing = FALSE, len = 1,
                              null.ok = FALSE)
  checkmate::assert_character(driver_name, len = 1, null.ok = FALSE,
                              any.missing = FALSE)
  checkmate::assert_vector(source,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_vector(records,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )
  checkmate::assert_vector(fields,
                           any.missing = FALSE, min.len = 1,
                           null.ok = TRUE, unique = TRUE
  )

  final_result <- list()
  from_query <- from_table_names <- NULL

  # check the id_position and id_column name
  if (all(!is.null(id_position) & !is.null(id_col_name))) {
    stop("Cannot specify both 'id_position' and 'id_col_name' at
         the same time.")
  }

  # establishing the connection to the server
  con <- connect_to_server(dbms, driver_name, host, database_name,
                           user, password, port)

  # listing the names of the tables present in the database
  tables <- DBI::dbListTables(conn = con)
  table_names <- NULL
  # closing the connection
  pool::poolClose(con)


  # separate the sources
  idx <- which(source %in% tables)
  if (length(idx) > 0) {
    table_names <- source[idx]
    source <- source[-idx]
  }

  # fetch data using SQL query
  if (length(source) > 0) {
    from_query <- fetch_data_from_query(source, dbms, tables,
                                        driver_name, host, database_name,
                                        user, password, port)
    final_result <- c(final_result, from_query)
  }

  # fetch data from tables
  if (length(table_names) > 0) {
    from_table_names <- sql_select_data(table_names, dbms, id_col_name,
                                       fields, records, id_position,
                                       driver_name, host, database_name,
                                       user, password, port)
    final_result <- c(final_result, from_table_names)
  }

  # return the datasets of interest
  final_result
}

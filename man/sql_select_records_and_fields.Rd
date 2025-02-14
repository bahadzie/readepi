% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_servers_helpers.R
\name{sql_select_records_and_fields}
\alias{sql_select_records_and_fields}
\title{Select specified records and fields from a table}
\usage{
sql_select_records_and_fields(
  table,
  record,
  id_column_name,
  field,
  id_pos,
  dbms,
  driver_name,
  host,
  database_name,
  user,
  password,
  port
)
}
\arguments{
\item{table}{the table name}

\item{record}{a vector or a comma-separated string of subset of subject IDs.}

\item{id_column_name}{the column names that unique identify the records in
the tables}

\item{field}{a vector of strings where each string is a comma-separated list
of column names.}

\item{id_pos}{a vector of the column positions of the variable that
unique identifies the subjects in each table}

\item{dbms}{the database management system type}

\item{driver_name}{the driver name}

\item{host}{host server name}

\item{database_name}{the database name}

\item{user}{the user name}

\item{password}{the user's password}

\item{port}{the server port ID}
}
\value{
a data frame with the specified columns and records
}
\description{
Select specified records and fields from a table
}
\examples{
result <- sql_select_records_and_fields(
 table = "author",
 record = c("1", "20", "50"),
 id_column_name = "author_id",
 field = c("author_id", "last_name"),
 id_pos = NULL,
 dbms = "MySQL",
 driver_name = "",
 host = "mysql-rfam-public.ebi.ac.uk",
 database_name = "Rfam",
 user = "rfamro",
 password = "",
 port = 4497
)

}

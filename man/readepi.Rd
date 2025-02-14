% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readepi.R
\name{readepi}
\alias{readepi}
\title{Import data from different sources into R}
\usage{
readepi(
  credentials_file = NULL,
  file_path = NULL,
  records = NULL,
  fields = NULL,
  id_position = NULL,
  id_col_name = NULL,
  ...
)
}
\arguments{
\item{credentials_file}{the path to the file with the user-specific
credential details
for the projects of interest. It is required when importing data from DBMS.
This is a tab-delimited file with the following columns:
\enumerate{
\item user_name: the user name
\item password: the user password (for REDCap, this corresponds to the
\strong{token} that serves as password to the project)
\item host_name: the host name (for MS SQL servers) or the URI (for REDCap)
\item project_id: the project ID or the name of the database
you are access to.
\item comment: a summary description about the project or database
of interest
\item dbms: the name of the DBMS: Possible values are: 'REDCap',
'SQLServer', 'MySQL', 'PostgreSQL', etc...
\item port: the port ID
}
Use the \code{show_example_file()} function to display the structure of
the template credentials file}

\item{file_path}{the path to the file to be read. When several files need to
be imported from a directory, this should be the path to that directory}

\item{records}{a vector or a comma-separated string of subject IDs.
When specified, only these records will be imported.}

\item{fields}{a vector or a comma-separated string of column names.
If provided, only those columns will be imported.}

\item{id_position}{the column position of the variable that unique identifies
the subjects. When the name of the column with the subject IDs is known,
this can be provided using the \code{id_col_name} argument}

\item{id_col_name}{the column name with the subject IDs.}

\item{...}{additional arguments passed to the readepi function.
These are enumarated in the vignette.}
}
\value{
a list of data frames.
}
\description{
the function allows import of data from files, folders, or
health information systems (HIS)
The HIS consist of database management systems (DBMS) and website of public
data collection.
}
\examples{
# reading from a MS SQL server
data <- readepi(
  credentials_file = system.file("extdata", "test.ini", package = "readepi"),
  project_id = "Rfam",
  driver_name = "",
  source = "author"
)
}

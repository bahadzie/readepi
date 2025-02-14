% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_from_file.R
\name{read_from_file}
\alias{read_from_file}
\title{Read data from file or directory}
\usage{
read_from_file(
  file_path,
  sep = NULL,
  format = NULL,
  which = NULL,
  pattern = NULL
)
}
\arguments{
\item{file_path}{the path to the file to be read. When several files need to
be imported from a directory, this should be the path to that directory}

\item{sep}{the separator between the columns in the file. This is only
required for space-separated files}

\item{format}{a string used to specify the file format. This is useful when
a file does not have an extension, or has a file extension that does not
match its actual type}

\item{which}{a string used to specify the name of the excel sheet to import}

\item{pattern}{when specified, only files with this suffix will be imported
from the specified directory}
}
\value{
a list of 1 (when reading from file) or several (when reading from
directory or reading several excel sheets) data frames
}
\description{
Read data from file or directory
}
\examples{
data <- read_from_file(
 file_path = system.file("extdata", "test.txt", package = "readepi"),
 sep = NULL,
 format = NULL,
 which = NULL,
 pattern = NULL
)
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_from_file-helpers.R
\name{get_base_name}
\alias{get_base_name}
\title{Get file base name}
\usage{
get_base_name(x)
}
\arguments{
\item{x}{the file path}
}
\value{
the file base name
}
\description{
Get file base name
}
\examples{
base_name <- get_base_name(
 x = system.file("extdata", "test.txt", package = "readepi")
)
}

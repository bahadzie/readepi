% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_from_redcap-helpers.R
\name{redcap_read_fields}
\alias{redcap_read_fields}
\title{Subset fields from a REDCap project}
\usage{
redcap_read_fields(fields, uri, token, id_position)
}
\arguments{
\item{fields}{a vector or a comma-separated string of column names}

\item{uri}{the URI of the REDCap project}

\item{token}{the user-specific string that serves as the password for a
project}

\item{id_position}{the column position of the variable that unique identifies
the subjects}
}
\value{
a list with the project data and its associated metadata with the
fields of interest
}
\description{
Subset fields from a REDCap project
}

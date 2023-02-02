
<!-- README.md is generated from README.Rmd. Please edit that file -->

# readepi

*readepi* provides functions for importing epidemiological data into
**R** from common *health information systems*.

<!-- badges: start -->

[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R-CMD-check](https://github.com/epiverse-trace/readepi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/epiverse-trace/readepi/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/epiverse-trace/readepi/branch/main/graph/badge.svg)](https://app.codecov.io/gh/epiverse-trace/readepi?branch=main)
[![lifecycle-concept](https://raw.githubusercontent.com/reconverse/reconverse.github.io/master/images/badge-concept.svg)](https://www.reconverse.org/lifecycle.html#concept)
<!-- badges: end -->

## Installation

You can install the development version of readepi from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
#devtools::install_github("epiverse-trace/readepi", build_vignettes = TRUE)
suppressPackageStartupMessages(library(readepi))
```

## Vignette

``` r
browseVignettes("readepi")
```

# Reading data from file or directory

The **readepi()** function can read read data from various source
including various file formats. It is based on the **rio** R package,
hence can import data from all file format supported by that one. See
[here](https://cran.r-project.org/web/packages/rio/vignettes/rio.html)
for more details about the file formats allowed by `rio`.  
Additionally, it can read in data from a space-separated file or read
specific or all files from a specified directory. When reading data from
file or directory, the function expects the following arguments:  
`file.path`: the path to the file to be read. When several files need to
be imported from a directory, this should be the path to that
directory,  
`sep`: the separator between the columns in the file. This is only
required for space-separated files,  
`format`: a string used to specify the file format. This is useful when
a file does not have an extension, or has a file extension that does not
match its actual type,  
`which`: which a string used to specify which objects should be
extracted (e.g. the name of the excel sheet to import),  
`pattern`: when specified, only files with this suffix will be imported
from the specified directory.  
The function will return either a data frame (if import from file) or a
list of data frames (if several files were imported from a directory).

## importing data from JSON file

``` r
file = system.file("extdata", "test.json", package = "readepi")
data = readepi(file.path = file)
```

## importing data from excel file with 2 sheets

here we are importing from the second excel sheet

``` r
file = system.file("extdata", "test.xlsx", package = "readepi")
data = readepi(file.path = file, which = "Sheet2")
```

## importing data from several files in a directory

``` r
# reading all files in the given directory
dir.path = "inst/extdata"
data = readepi(file.path = dir.path)

# reading only txt files
data = readepi(file.path = dir.path, pattern = "txt")
```

# Reading data from relational database management systems (RDBMS): HDSS, EMRS, REDCap

Research data are usually stored in either relational databases or NoSQL
databases. At the MRCG, project data are stored in relational databases.
The HDSS and EMRS host databases that run under MS SQL Server, while
REDCap (that uses an EAV schema) run under a MySQL server.  
To import data from a HDSS or EMRS (MS SQL Server) into R, some
dependencies need to be installed first.

## installation of dependencies

If you are using a Unix-based system, you will need to install the MS
ODBC driver that is compatible with the version of the target MS SQL
server. For **SQL server 2019, version 15.0**, we installed **ODBC
Driver 17 for SQL Server** on the mac OS. This is compatible with the
MRCG test server `robin.mrc.gm`. Details about how to install a driver
can be found
[here](https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/install-microsoft-odbc-driver-sql-server-macos?view=sql-server-ver15).  
Once installed, the list of drivers can be displayed in R using:
`odbc::odbcListDrivers()`.  
It is important to view the data that is stored in the MS SQL server. I
recommend to install a GUI such as `Azure Data Studio`.

## importing data from RDBMS into R

For testing purpose, we were given access to the test server
`robin.mrc.gm`. Users should be granted with read access to be able to
pull data from the test server.  
The **read_epi()** function can read data from the above RDBMS. It
expects the following arguments:  
`credentials.file`: the path to the file with the user-specific
credential details for the projects of interest. This is a tab-delimited
file with the following columns:

- user_name: the user name,  
- password: the user password (for REDCap, this corresponds to the
  **token** that serves as password to the project),  
- host_name: the host name (for HDSS and EMRS) or the URI (for
  REDCap),  
- project_id: the project ID (for REDCap) or the name of the database
  (for HDSS and EMRS) you are access to,  
- comment: a summary description about the project or database of
  interest,  
- dbms: the name of the DBMS: ‘redcap’ or ‘REDCap’ when reading from
  REDCap, ‘sqlserver’ or ‘SQLServer’ when reading from MS SQL Server,  
- port: the port ID (used for MS SQL Servers only).  
  `project.id` for relational DB, this is the name of the database that
  contains the table from which the data should be pulled. Otherwise, it
  is the project ID you were given access to. Note that this should be
  similar to the value of the **project_id** field in the credential
  file.  
  `driver.name` the name of the MS driver (only for HDSS and EMRS). use
  `odbc::odbcListDrivers()` to display the list of installed drivers,  
  `table.name`: the name of the target table (only for HDSS and EMRS),  
  `records`: a vector or a comma-separated string of a subset of subject
  IDs. When specified, only the records that correspond to these
  subjects will be imported,  
  `fields`: a vector or a comma-separated string of column names. If
  provided, only those columns will be imported,  
  `id.position`: the column position of the variable that unique
  identifies the subjects. This should only be specified when the column
  with the subject IDs is not the first column. default is 1.

The function returns a list with 2 data frames (data and metadata) when
reading from REDCap. A data frame otherwise.

### importing from REDCap

we were given access to the
\*\*Pats\_\_Covid_19_Cohort_1\_Screening\*\*.

``` r
# display the structure of the credentials file
show_example_file()
# credentials.file = system.file("extdata", "test.ini", package = "readepi")

# reading all fields and records the project
data = readepi(credentials.file, project.id="Pats__Covid_19_Cohort_1_Screening")
project.data = data$data
project.metadeta = data$metadata

# reading specified fields and all records from the project
fields = c("day_1_q_ran_id","redcap_event_name","day_1_q_1a","day_1_q_1b","day_1_q_1c","day_1_q_1","day_1_q_2","day_1_q_3","day_1_q_4","day_1_q_5")
data = readepi(credentials.file, project.id="Pats__Covid_19_Cohort_1_Screening", fields = fields)

# reading specified records and all fields from the project
records = c("C10001/3","C10002/1","C10003/7","C10004/5","C10005/9","C10006/8","C10007/6","C10008/4","C10009/2","C10010/1")
data = readepi(credentials.file, project.id="Pats__Covid_19_Cohort_1_Screening", records =  records)

# reading specified records and fields from the project
data = readepi(credentials.file, project.id="Pats__Covid_19_Cohort_1_Screening", records =  records, fields = fields)
```

### importing from HDSS or EMRS

#### show list of tables in the database

To show the list of tables in the database of interest:

``` r
showTables(credentials.file=system.file("extdata", "test.ini", package = "readepi"), project.id="IBS_BHDSS", driver.name="ODBC Driver 17 for SQL Server")
```

#### importing data

``` r
# reading all fields and all records from one table (`dss_events`)
data = readepi(credentials.file, project.id="IBS_BHDSS", driver.name = "ODBC Driver 17 for SQL Server", table.name = "dss_events")

# reading specified fields and all records from one table
data = readepi(credentials.file, project.id="IBS_BHDSS", driver.name = "ODBC Driver 17 for SQL Server", table.name = "dss_events", fields = fields)

# reading specified records and all fields from one table
data = readepi(credentials.file, project.id="IBS_BHDSS", driver.name = "ODBC Driver 17 for SQL Server", table.name = "dss_events", records = records)

# reading specified fields and records one the table
data = readepi(credentials.file, project.id="IBS_BHDSS", driver.name = "ODBC Driver 17 for SQL Server", table.name = "dss_events", records = records, fields = fields)

# reading data from several tables
table.names = "accounts,account_books,account_currencies" #can also be table.names = c("account"s,"account_books","account_currencies")
data = readepi(credentials.file, project.id="IBS_BHDSS", driver.name = "ODBC Driver 17 for SQL Server", table.name = table.names)

# reading data from several tables and subsetting fields across tables
table.names = "accounts,account_books,account_currencies" #can also be table.names = c("account"s,"account_books","account_currencies")
#note that first string in the field vector corresponds to names to be subset from the first table specified in the `table.name` argument  
fields = c("id,name,balance,created_by", "id,status,name", "id,name")
data = readepi(credentials.file, project.id="IBS_BHDSS", driver.name = "ODBC Driver 17 for SQL Server", table.name = table.names, fields = fields)

# reading data from several tables and subsetting records across tables 
#note that first string in the records vector corresponds to the subject ID to be subset from the first table specified in the `table.name` argument and so on... When the ID column is not the first column in a table, use the `id.position` 
records = c("3,8,13", "1,2,3", "1")
data = readepi(credentials.file, project.id="IBS_BHDSS", driver.name = "ODBC Driver 17 for SQL Server", table.name = table.names, records = records)

# reading data from several tables and subsetting records and fields across tables 
fields = c("id,name,balance,created_by", "id,status,name", "id,name")
records = c("3,8,13", "1,2,3", "1")
data = readepi(credentials.file, project.id="IBS_BHDSS", driver.name = "ODBC Driver 17 for SQL Server", table.name = table.names, records = records, fields = fields)
```

# Processing the genomic data

To account for the genomic data in the analysis, our suggested input
file format is: [FASTQ](https://en.wikipedia.org/wiki/FASTQ_format)
format. This is a common file format in the field of
**Bioinformatics**.  
The `readepi` package contains functions that can perform genome
assembly on genomic sequences from [nanopore](https://nanoporetech.com)
as well as [illumina](https://www.illumina.com) platform.  
It also contains a function for **clade assignment** using both
[nextclade](https://clades.nextstrain.org/) and
[pangolin](https://cov-lineages.org/resources/pangolin.html).  
Currently, these function can only be run on a **Linux system** or **Mac
OS**.

## Genome assembly of nanopore reads

Nanopore sequences are assembled using the
[ARTIC](https://artic.network/ncov-2019/ncov2019-bioinformatics-sop.html)
pipeline. After creating the **conda environment** for ARTIC, use the
function `genome_assembly()` with the following parameters:

- `input.dir`: the path to the folder with the input fastq files. Each
  sample/barcode will have a directory in this folder,  
- `assembly.dir`: the path to the folder where the output files from the
  genome assembly will be stored,  
- `consensus.fasta.dir`: the path to the folder where the merged
  consensus fasta file will be stored. That file is the one that will be
  used for the subsequent analysis,  
- `num.samples`: the number of samples in the dataset. This will serve
  for the parallelisation purpose to speed up the genome assembly
  process,  
- `device`: the name of the nanopore sequencing device (either *MinION*
  or *PromethION*),  
- `partition`: the partition name. Only set this when running on a HPC,
  default is NULL.

### Genome assembly of nanopore reads on PC (Mac OS or linux system)

``` r
genome_assembly(input.dir="/Users/karimmane/Documents/Karim/LSHTM/TRACE_dev/Genomic_data/Covadis", 
                assembly.dir="/Users/karimmane/Documents/Karim/LSHTM/TRACE_dev/Genomic_data/genome_assembly", 
                consensus.fasta.dir="/Users/karimmane/Documents/Karim/LSHTM/TRACE_dev/Genomic_data/consensus_dir", 
                num.samples=60, 
                device="MinION", 
                partition=NULL)
```

### Genome assembly of nanopore reads on HPC

``` r
genome_assembly(input.dir="/nfsscratch/Karim/LSHTM/Covadis", 
                assembly.dir="/nfsscratch/Karim/LSHTM/assembly_results", 
                consensus.fasta.dir="/nfsscratch/Karim/LSHTM/consensus_dir", 
                num.samples=60, 
                device="MinION", 
                partition="standard")
```

## Genome assembly of illumina reads

## Clade assignment

After generating the consensus genome for each samples and merging them
into a single file (this is done by the step above), the clade
assignment can be performed using the `clade_assignment()`. This
function assumes that both **nextclade** and **pangolin** are installed
using **conda**. The `clade_assignment()` function needs arguments
below:

- `merged.fasta`: path to the fasta file with the sequences from all
  samples. This corresponds to file in the folder specified by the
  `consensus.fasta.dir` argument in the genome assembly step,  
- `output.dir`: path to the folder where the clade assignment results
  will be stored.

``` r
clade_assignment(merged.fasta="/Users/karimmane/Documents/Karim/LSHTM/TRACE_dev/Genomic_data/consensu_dir/consensus_genomes.fasta", 
                 output.dir="/Users/karimmane/Documents/Karim/LSHTM/TRACE_dev/Genomic_data/clade_assignment")
```

## Development

### Lifecycle

This package is currently a *concept*, as defined by the [RECON software
lifecycle](https://www.reconverse.org/lifecycle.html). This means that
essential features and mechanisms are still being developed, and the
package is not ready for use outside of the development team.

### Contributions

Contributions are welcome via [pull
requests](https://github.com/epiverse-trace/readepi/pulls).

Contributors to the project include:

- Karim Mané (author)
- Thibaut Jombart (author)

### Code of Conduct

Please note that the linelist project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

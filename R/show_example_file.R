#' Display the structure of the credentials file
#' @export
#' @examples
#' show_example_file()
show_example_file <- function() {
  example_data <- data.table::fread(system.file("extdata", "test.ini",
                                                package = "readepi"))
  print(example_data)
}

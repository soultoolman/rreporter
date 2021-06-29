#' store generics
#' @param ... refer to specified method for details.
#' @export
store <- function(...) UseMethod("store")

#' read generics
#' @param ... refer to specified method for details.
#' @export
read <- function(...) UseMethod(("read"))


#' FileBackend
#' @param reporter_dir a directory that save report data
#' @return FileBackend object
#' @export
FileBackend <- function(reporter_dir=NULL) {
  if (is.null(reporter_dir)) {
    reporter_dir <- Sys.getenv("REPORTER_DIR")
  }
  if (reporter_dir == "") {
    reporter_dir <- "."
  }
  if (! dir.exists(reporter_dir)) {
    dir.create(reporter_dir)
  }
  backend <- list(
    reporter_dir = reporter_dir
  )
  class(backend) <- append(class(backend), c("Backend", "FileBackend"))
  return(backend)
}


#' get report file for FileBackend
#' @importFrom glue glue
#' @param backend FileBackend object
#' @param report_id report UUID
#' @return report file path
#' @export
get_report_file <- function(backend, report_id) {
  file <- file.path(
    backend$reporter_dir,
    glue("reporter-report-{report_id}.json")
  )
  return(file)
}


#' convert FileBackend to character
#' @importFrom glue glue
#' @param x FileBackend object
#' @param ... refer to as.character for details.
#' @return FileBackend character
#' @export
as.character.FileBackend <- function(x, ...) {
  return(glue(
    "<FileBackend: {report_dir}>",
    reporter_dir = x$reporter_dir
  ))
}


#' read report from FileBackend
#' @importFrom glue glue
#' @importFrom jsonlite fromJSON
#' @param backend FileBackend object
#' @param report_id report UUID
#' @param ... refer to read for details.
#' @return report data
#' @export
read.FileBackend <- function(backend, report_id, ...) {
  file <- get_report_file(backend, report_id)
  if (! file.exists(file)) {
    stop(glue("report file {file} doesn't exists."))
  }
  json <- readLines(file)
  return(fromJSON(json))
}


#' store report to FileBackend
#' @importFrom jsonlite toJSON
#' @param backend FileBackend object
#' @param report_id an UUID string
#' @param data list object
#' @param ... refer to store for details
#' @return file path
#' @export
store.FileBackend <- function(backend, report_id, data, ...) {
  file <- get_report_file(backend, report_id)
  json <- toJSON(
    data,
    auto_unbox = TRUE
  )
  writeLines(json, file)
  return(file)
}


#' Report
#' @importFrom uuid UUIDgenerate
#' @param report_id UUID string or NULL
#' @param backend Backend object
#' @return Report object
#' @export
Report <- function(report_id=NULL, backend=NULL) {
  # report_id
  if (is.null(report_id)) {
    report_id <- UUIDgenerate()
  }
  report_id <- gsub("-", "", report_id)

  # backend
  if (is.null(backend)) {
    backend <- FileBackend()
  }
  report = list(
    report_id = report_id,
    backend = backend,
    data = list()
  )
  class(report) <- append(class(report), "Report")
  return(report)
}


#' get data length of report
#' @param x Report object
#' @export
length.Report <- function(x) {
  return(length(x$data))
}


#' convert Report object to character
#' @importFrom glue glue
#' @param x Report object
#' @param ... refer to as.character for details.
#' @export
as.character.Report <- function(x, ...) {
  return(glue("<Report: {report_id}>", report_id=x$report_id))
}


#' add variable to report
#' @param report Report object
#' @param name variable name
#' @param value variable value
#' @return Report object
#' @export
add <- function(report, name, value) {
  report$data[[name]] <- value
  return(report)
}


#' access variable from report
#' @importFrom glue glue
#' @param report Report object
#' @param name variable name
#' @return variable data
#' @export
access <- function(report, name) {
  if (! name %in% names(report$data)) {
    stop(glue("{name} not found."))
  }
  return(report$data[[name]])
}


#' read data from report
#' @param report Report object
#' @param name variable name
#' @param ... refer to read for details.
#' @export
read.Report <- function(report, name, ...) {
  report$data <- read(report$backend, report$report_id)
  return(report)
}


#' save report to backend
#' @param report Report object
#' @param ... refer to store for details.
#' @export
store.Report <- function(report, ...) {
  return(store(report$backend, report$report_id, report$data))
}

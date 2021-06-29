library(rreporter)


test_that("FileBackend", {
  backend <- FileBackend()
  expect_equal(backend$reporter_dir, ".")

  reporter_dir <- tempdir()
  backend <- FileBackend(reporter_dir)
  expect_equal(backend$reporter_dir, reporter_dir)

  reporter_dir <- tempdir()
  Sys.setenv(REPORTER_DIR = reporter_dir)
  backend <- FileBackend()
  expect_equal(backend$reporter_dir, reporter_dir)

  reporter_dir <- tempdir()
  file <- file.path(reporter_dir, "reporter-report-xxx.json")
  backend <- FileBackend(reporter_dir)
  expect_equal(get_report_file(backend, "xxx"), file)

  expect_false(file.exists(file))
  store(backend, "xxx", list(foo="bar"))
  expect_true(file.exists(file))
  data <- read(backend, "xxx")
  expect_equal(data, list(foo="bar"))
})


test_that("reporter", {
  reporter_dir <- tempdir()
  backend <- FileBackend(reporter_dir)
  report <- Report(backend = backend)
  expect_equal(report$data, list())
  report <- add(report, "foo", "bar")
  expect_equal(report$data, list(foo="bar"))
  expect_equal(access(report, "foo"), "bar")
  file <- file.path(
    reporter_dir,
    glue("reporter-report-{report_id}.json", report_id=report$report_id)
  )
  expect_false(file.exists(file))
  store(report)
  expect_true(file.exists(file))
  report <- Report(report$report_id, backend)
  expect_equal(report$data, list())
  report <- read(report)
  expect_equal(report$data, list(foo="bar"))
})

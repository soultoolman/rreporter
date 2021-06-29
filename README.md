## rrporeter: saving intermediate results gracefully

Usually, we use `print` or `message` for saving
intermediate results of an R script. This is not graceful.
`rrporter` help you do it.

### installation

```R
install.packages("rrporter")
```

### usage


#### quick start

```R
library(rrporter)


report <- Report()  # initialize report object
add(report, "foo", "bar")  # add variable to report
store(report)  # save report to file
print(report$report_id)  # you need this report ID only.
```

In another script:

```R
library(rreporter)

report_id <- "xxx"  # the ID you want to read
report <- Report(report_id)  # initialize using ID
report <- read(report)  # load from backend

access(report, "foo")  # will return "bar"
```

#### FAQs

##### How to save to specified directory?

`rrporter` save to report data to current diretory, there're 2 ways to change it:

1. define environment variable `REPORTER_DIR`

```
export REPORTER_DIR=/path/to/reporter
```

2. custom backend object

```R
backend <- FileBackend("/path/to/reporter")
report <- Report(backend = backend)
```

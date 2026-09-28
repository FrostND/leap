
test_that("cols_standard renames core columns and preserves their values", {
  data <- data.frame(
    person = c("a", "b"),
    visit = c(1L, 2L),
    score = c(10, 12),
    visit_date = as.Date(c("2025-01-01", "2025-01-08")),
    site = c("north", "south")
  )

  result <- cols_standard(
    data,
    client = "person",
    session = "visit",
    outcome = "score",
    date = "visit_date"
  )

  expect_named(
    result,
    c("client_id", "session_id", "outcome", "session_date", "site")
  )
  expect_identical(result$client_id, data$person)
  expect_identical(result$session_id, data$visit)
  expect_identical(result$outcome, data$score)
  expect_identical(result$session_date, data$visit_date)
  expect_identical(result$site, data$site)
})

test_that("cols_standard leaves the date column alone when date is omitted", {
  data <- data.frame(
    person = "a",
    visit = 1L,
    score = 10,
    visit_date = as.Date("2025-01-01")
  )

  result <- cols_standard(
    data, client = "person", session = "visit", outcome = "score"
  )

  expect_named(
    result,
    c("client_id", "session_id", "outcome", "visit_date")
  )
})

test_that("cols_standard requires the specified source columns", {
  data <- data.frame(person = "a", visit = 1L, score = 10)

  expect_error(
    cols_standard(
      data, client = "missing", session = "visit", outcome = "score"
    )
  )

  expect_error(
    cols_standard(
      data, client = "person", session = "visit",
      outcome = "score", date = "missing"
    )
  )
})

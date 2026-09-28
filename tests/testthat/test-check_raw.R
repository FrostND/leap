
test_that("check_raw identifies required and derived columns", {
  data <- data.frame(
    client_id = c("a", "b"),
    session_date = as.Date(c("2025-01-01", "2025-01-02")),
    outcome = c(10, 12)
  )

  result <- check_raw(data)

  expect_identical(
    result$variable,
    c(
      "client", "date", "outcome", "session_lag", "episode_id",
      "episode_session", "client_episode_id", "n_episodes"
    )
  )
  expect_true(all(result$present[1:3]))
  expect_false(any(result$present[4:8]))
  expect_true(all(result$action[1:3] == "Ready"))
  expect_identical(result$action[4], "Run add_session_lag()")
  expect_identical(result$action[5], "Run add_episode_id()")
})

test_that("check_raw accepts custom required column names", {
  data <- data.frame(
    person = "a",
    visit_date = as.Date("2025-01-01"),
    score = 10
  )

  result <- check_raw(
    data, client = "person", date = "visit_date", outcome = "score"
  )

  expect_identical(result$column[1:3], c("person", "visit_date", "score"))
  expect_true(all(result$present[1:3]))
})

test_that("check_raw reports missing required columns", {
  result <- check_raw(data.frame(client_id = "a"))

  expect_false(result$present[result$variable == "date"])
  expect_false(result$present[result$variable == "outcome"])
  expect_identical(
    result$action[result$variable == "date"],
    "Supply or specify this column"
  )
})

test_that("check_raw warns about invalid or missing values", {
  data <- data.frame(
    client_id = "a",
    session_date = "2025-01-01",
    outcome = 10
  )
  expect_warning(check_raw(data), "not stored as a Date")

  data$session_date <- as.Date(data$session_date)
  data$outcome <- NA_real_
  expect_warning(check_raw(data), "missing outcome observation")
})

test_that("check_raw requires a data frame", {
  expect_error(check_raw(list(client_id = "a")), "must be a data frame")
})

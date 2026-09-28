

test_that("describe_episodes summarizes each episode number across clients", {
  data <- data.frame(
    client_id = c(rep("a", 5), rep("b", 5)),
    episode_id = c(1, 1, 1, 2, 2, 1, 1, 2, 2, 2),
    session_date = as.Date(c(
      "2025-01-01", "2025-01-08", "2025-01-15",
      "2025-04-01", "2025-04-08",
      "2025-02-01", "2025-02-15",
      "2025-05-01", "2025-05-01", "2025-05-15"
    )),
    session_lag = c(NA, 7, 7, NA, 7, NA, 14, NA, 0, 14),
    outcome = c(10, 12, 14, 15, 17, 8, 10, 9, 11, 13)
  )

  result <- describe_episodes(data)

  expect_equal(result$episode_id, c(1, 2))
  expect_equal(result$n_clients, c(2, 2))
  expect_equal(result$n_sessions, c(5, 5))
  expect_equal(result$mean_sessions, c(2.5, 2.5))
  expect_equal(result$mean_duration_days, c(14, 10.5))
  expect_equal(result$mean_lag_days, c(9.33, 10.5))
  expect_equal(result$mean_outcome, c(10.8, 13))
})

test_that("describe_episodes excludes missing outcomes from the mean", {
  data <- data.frame(
    client_id = c("a", "a"),
    episode_id = c(1, 1),
    session_date = as.Date(c("2025-01-01", "2025-01-08")),
    session_lag = c(NA_real_, 7),
    outcome = c(10, NA_real_)
  )

  result <- describe_episodes(data)

  expect_equal(result$mean_outcome, 10)
  expect_equal(result$mean_duration_days, 7)
})

test_that("describe_episodes requires its standard columns", {
  data <- data.frame(
    client_id = "a",
    episode_id = 1,
    session_date = as.Date("2025-01-01"),
    outcome = 10
  )

  expect_error(describe_episodes(data))
})

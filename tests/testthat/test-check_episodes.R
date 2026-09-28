
make_episode_data <- function() {
  data.frame(
    client_id = c(rep("a", 10), rep("b", 5)),
    episode_id = c(rep(1L, 5), rep(2L, 5), rep(1L, 5)),
    episode_session = rep(1:5, 3),
    session_date = as.Date("2025-01-01") + rep(0:4, 3),
    outcome = 1:15
  )
}

test_that("check_episodes summarizes valid episode data", {
  result <- check_episodes(make_episode_data())

  expect_equal(result$obs, 15)
  expect_equal(result$clients, 2)
  expect_equal(result$episodes, 3) # Client–episode combinations
  expect_equal(result$na_total, 0)
  expect_equal(result$na_outcomes, 0)
  expect_equal(result$na_dates, 0)
  expect_true(result$correctly_ordered)
  expect_true(result$sequential_sessions)
  expect_true(result$chronological_dates)
})

test_that("check_episodes reports missing values", {
  data <- make_episode_data()
  data$outcome[1] <- NA

  expect_warning(
    result <- check_episodes(data),
    "missing outcome"
  )
  expect_equal(result$na_total, 1)
  expect_equal(result$na_outcomes, 1)

  data <- make_episode_data()
  data$session_date[1] <- NA

  expect_warning(
    result <- check_episodes(data),
    "missing session date"
  )
  expect_equal(result$na_dates, 1)
  expect_true(is.na(result$chronological_dates))
})

test_that("check_episodes detects ordering problems", {
  data <- make_episode_data()
  data$episode_session[3] <- 4L

  expect_warning(
    result <- check_episodes(data),
    "non-sequential"
  )
  expect_false(result$sequential_sessions)

  data <- make_episode_data()
  data$session_date[1:2] <- data$session_date[2:1]

  expect_warning(
    result <- check_episodes(data),
    "not in chronological order"
  )
  expect_false(result$chronological_dates)
})

test_that("check_episodes requires its standard columns", {
  data <- make_episode_data()
  data$episode_session <- NULL

  expect_error(check_episodes(data))
})

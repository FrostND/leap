
make_break_data <- function() {
  data.frame(
    client_id = c("a", "a", "a", "a", "b", "b"),
    episode_id = c(1L, 1L, 2L, 2L, 1L, 1L),
    episode_session = c(1L, 2L, 1L, 2L, 1L, 2L),
    session_date = as.Date(c(
      "2025-01-01", "2025-01-08",
      "2025-04-08", "2025-04-15",
      "2025-02-01", "2025-02-08"
    )),
    outcome = c(10, 16, 12, 18, 2, 4),
    client_episode_id = c("a_1", "a_1", "a_2", "a_2", "b_1", "b_1")
  )
}

test_that("episode_breaks compares consecutive episodes within clients", {
  data <- make_break_data()
  data <- data[c(4, 6, 2, 3, 5, 1), ] # Deliberately unsorted

  result <- episode_breaks(data)

  expect_equal(nrow(result), 1)
  expect_identical(result$client_id, "a")
  expect_equal(result$prior_episode, 1)
  expect_equal(result$next_episode, 2)
  expect_equal(result$prior_discharge, 16)
  expect_equal(result$next_intake, 12)
  expect_equal(result$bad_enough_level, 4)
  expect_equal(result$days_between, 90)
  expect_equal(result$months_between, 90 / 30.44)
  expect_equal(result$loss_per_month, 4 / (90 / 30.44))
})

test_that("episode_breaks reverses the score direction when lower is better", {
  result <- episode_breaks(make_break_data(), higher_is_better = FALSE)

  expect_equal(result$bad_enough_level, -4)
  expect_equal(result$loss_per_month, -4 / (90 / 30.44))
})

test_that("episode_breaks leaves loss per month missing for a zero-day break", {
  data <- make_break_data()
  data$session_date[3] <- as.Date("2025-01-08")

  result <- episode_breaks(data)

  expect_equal(result$days_between, 0)
  expect_true(is.na(result$loss_per_month))
})

test_that("episode_breaks returns an empty data frame without repeat episodes", {
  data <- subset(make_break_data(), episode_id == 1)

  result <- episode_breaks(data)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
  expect_named(result, c(
    "client_id", "prior_episode", "next_episode",
    "prior_discharge", "next_intake", "bad_enough_level",
    "days_between", "months_between", "loss_per_month"
  ))
})

test_that("episode_breaks requires its input columns", {
  data <- make_break_data()
  data$client_episode_id <- NULL

  expect_error(episode_breaks(data))
})

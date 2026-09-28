

test_that("add_episode_id starts a new episode at the delimiter", {
  data <- data.frame(
    client_id = c("a", "a", "a", "a", "a", "b", "b"),
    session_lag = c(NA, 89, 90, NA, 120, NA, 90),
    outcome = 1:7
  )

  result <- add_episode_id(data)

  expect_identical(result$episode_id, c(1L, 1L, 2L, 2L, 3L, 1L, 2L))
  expect_identical(result$outcome, data$outcome)
})

test_that("add_episode_id uses a custom delimiter", {
  data <- data.frame(
    client_id = rep("a", 4),
    session_lag = c(NA, 29, 30, 90)
  )

  result <- add_episode_id(data, delimiter = 30)

  expect_identical(result$episode_id, c(1L, 1L, 2L, 3L))
})

test_that("add_episode_id requires client_id and session_lag", {
  expect_error(
    add_episode_id(data.frame(client_id = "a"))
  )
  expect_error(
    add_episode_id(data.frame(session_lag = NA_real_))
  )
})

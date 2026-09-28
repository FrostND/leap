

test_that("add_episode_vars creates episode variables from unsorted sessions", {
  data <- data.frame(
    row_id = 1:5,
    client_id = c("b", "a", "a", "b", "a"),
    session_date = as.Date(c(
      "2025-04-01", "2025-04-08", "2025-01-08",
      "2025-01-01", "2025-01-01"
    ))
  )

  result <- add_episode_vars(data)

  # Restore input order to compare each result with its source row.
  result <- result[order(result$row_id), ]

  expect_identical(result$session_lag, c(90, 90, 7, NA_real_, NA_real_))
  expect_identical(result$episode_id, c(2L, 2L, 1L, 1L, 1L))
  expect_identical(result$episode_session, c(1L, 1L, 2L, 1L, 1L))
  expect_equal(result$n_episodes, rep(2, 5))
  expect_identical(
    result$client_episode_id,
    c("b_2", "a_2", "a_1", "b_1", "a_1")
  )
})

test_that("add_episode_vars passes a custom delimiter to add_episode_id", {
  data <- data.frame(
    client_id = c("a", "a", "a"),
    session_date = as.Date(c(
      "2025-01-01", "2025-01-30", "2025-02-28"
    ))
  )

  result <- add_episode_vars(data, delimiter = 29)

  expect_identical(result$episode_id, c(1L, 2L, 3L))
  expect_equal(result$n_episodes, c(3, 3, 3))
})

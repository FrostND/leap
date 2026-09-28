

test_that("add_episode_session numbers sessions within each episode", {
  data <- data.frame(
    row_id = 1:6,
    client_id = c("a", "b", "a", "a", "b", "a"),
    episode_id = c(1, 1, 2, 1, 2, 2)
  )

  result <- add_episode_session(data)

  # split() may reorder rows, so compare in original row order.
  result <- result[order(result$row_id), ]

  expect_identical(result$episode_session, c(1L, 1L, 1L, 2L, 1L, 2L))
  expect_identical(result$row_id, data$row_id)
})

test_that("add_episode_session requires both ID columns", {
  expect_error(add_episode_session(data.frame(client_id = "a")))
  expect_error(add_episode_session(data.frame(episode_id = 1)))
})

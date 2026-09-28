
test_that("add_episode_count assigns each client their episode count", {
  data <- data.frame(
    client_id = c("a", "a", "a", "b", "b"),
    episode_id = c(1, 1, 2, 1, 1),
    outcome = c(10, 11, 12, 8, 9)
  )

  result <- add_episode_count(data)

  expect_identical(result$n_episodes, c(2, 2, 2, 1, 1))
  expect_identical(result$client_id, data$client_id)
  expect_identical(result$episode_id, data$episode_id)
  expect_identical(result$outcome, data$outcome)
})

test_that("add_episode_count requires both ID columns", {
  expect_error(
    add_episode_count(data.frame(client_id = "a"))
  )
  expect_error(
    add_episode_count(data.frame(episode_id = 1))
  )
})

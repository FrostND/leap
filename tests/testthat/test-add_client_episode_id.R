


test_that("add_client_episode_id combines client and episode IDs", {
  data <- data.frame(
    client_id = c("a", "a", "b"),
    episode_id = c(1, 2, 1),
    outcome = c(10, 12, 8)
  )

  result <- add_client_episode_id(data)

  expect_identical(result$client_episode_id, c("a_1", "a_2", "b_1"))
  expect_identical(result$client_id, data$client_id)
  expect_identical(result$episode_id, data$episode_id)
  expect_identical(result$outcome, data$outcome)
})

test_that("add_client_episode_id requires both ID columns", {
  expect_error(
    add_client_episode_id(data.frame(client_id = "a"))
  )
  expect_error(
    add_client_episode_id(data.frame(episode_id = 1))
  )
})




make_slope_data <- function() {
  data.frame(
    client_id = c(rep("a", 10), rep("b", 5)),
    episode_id = c(rep(1L, 5), rep(2L, 5), rep(1L, 5)),
    episode_session = rep(1:5, 3),
    outcome = c(
      2, 4, 6, 8, 10,   # a_1: slope 2
      10, 9, 8, 7, 6,   # a_2: slope -1
      5, 5, 5, 5, 5     # b_1: slope 0
    ),
    client_episode_id = c(
      rep("a_1", 5), rep("a_2", 5), rep("b_1", 5)
    ),
    n_episodes = c(rep(2L, 10), rep(1L, 5))
  )
}

test_that("episode_slopes estimates change and slope for each episode", {
  result <- episode_slopes(make_slope_data())

  expect_identical(result$client_id, c("a", "a", "b"))
  expect_equal(result$episode_id, c(1, 2, 1))
  expect_equal(result$n_sessions, c(5, 5, 5))
  expect_equal(result$n_episodes, c(2, 2, 1))
  expect_equal(result$pre, c(2, 10, 5))
  expect_equal(result$post, c(10, 6, 5))
  expect_equal(result$change, c(8, -4, 0))
  expect_equal(result$slope, c(2, -1, 0))
})

test_that("episode_slopes reverses direction when lower is better", {
  result <- episode_slopes(
    make_slope_data(),
    higher_is_better = FALSE
  )

  expect_equal(result$change, c(-8, 4, 0))
  expect_equal(result$slope, c(-2, 1, 0))
})

test_that("episode_slopes warns about short episodes", {
  data <- make_slope_data()
  data <- subset(
    data,
    client_episode_id != "a_1" | episode_session <= 3
  )

  expect_warning(
    result <- episode_slopes(data),
    "four or fewer sessions"
  )
  expect_equal(result$slope[result$client_id == "a" &
                              result$episode_id == 1], 2)
})

test_that("episode_slopes requires its input columns", {
  data <- make_slope_data()
  data$n_episodes <- NULL

  expect_error(episode_slopes(data))
})

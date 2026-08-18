


test_that("sample_episode first retains episode 1", {

  df <- episode_test_data()
  out <- sample_episodes(data = df, method = "first")

  expect_true(all(out$episode_id == 1))
  expect_equal(length(unique(out$client_id)), 2)
})



test_that("random episode sampling is reproducible", {

  df <- episode_test_data()
  out1 <- sample_episode(df, method = "random", seed = 1234)
  out2 <- sample_episode(df, method = "random", seed = 1234)

  expect_identical(out1, out2)
})

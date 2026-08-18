


test_that("cols_validate accepts existing columns", {
  df <- episode_test_data()
  expect_true(cols_validate(df, "client_id", "episode_id"))
  })


test_that("cols_validate reports missing columns", {
  df <- episode_test_data()
  expect_error(cols_validate(df, "client_id", "fake_variable"), "fake_variable")
})


test_that("plot_lag_density uses only positive, observed lags", {
  data <- data.frame(
    session_lag = c(NA_real_, -3, 0, 7, 14, 30, 60)
  )

  plot <- lot_lag_density(data)

  expect_s3_class(plot, "ggplot")
  expect_identical(plot$data$session_lag, c(7, 14, 30, 60))
  expect_equal(length(plot$layers), 1)
  expect_true(nrow(ggplot2::layer_data(plot, 1)) > 0)
})

test_that("plot_lag_density forwards smoothing and adds a delimiter", {
  data <- data.frame(session_lag = c(7, 14, 30, 60))

  plot <- lot_lag_density(data, delimiter = 90, smooth = 2)

  expect_equal(plot$layers[[1]]$stat_params$adjust, 2)
  expect_equal(length(plot$layers), 2)
  expect_true(all(
    ggplot2::layer_data(plot, 2)$xintercept == 90
  ))
  expect_equal(plot$coordinates$limits$x, c(0, 365))
})

test_that("plot_lag_density requires session_lag", {
  expect_error(lot_lag_density(data.frame(other = 1:4)))
})

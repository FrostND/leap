
test_that("lag_delimiter removes missing and non-positive lags", {
  local_mocked_bindings(
    estimate_delim = function(lags, method, multiplier, prob) {
      list(
        lags = lags,
        method = method,
        multiplier = multiplier,
        prob = prob
      )
    }
  )

  data <- data.frame(
    session_lag = c(NA_real_, 0, -2, 7, 14, 28)
  )

  result <- lag_delimiter(
    data, method = "quantile", multiplier = 3, prob = 0.8
  )

  expect_identical(result$lags, c(7, 14, 28))
  expect_identical(result$method, "quantile")
  expect_identical(result$multiplier, 3)
  expect_identical(result$prob, 0.8)
})

test_that("lag_delimiter uses the default estimation settings", {
  local_mocked_bindings(
    estimate_delim = function(lags, method, multiplier, prob) {
      list(method = method, multiplier = multiplier, prob = prob)
    }
  )

  result <- lag_delimiter(data.frame(session_lag = c(7, 14)))

  expect_identical(
    result,
    list(method = "iqr", multiplier = 2, prob = 0.95)
  )
})

test_that("lag_delimiter validates its input", {
  expect_error(lag_delimiter(data.frame(other = 7)))
  expect_error(
    lag_delimiter(data.frame(session_lag = 7), method = "unknown")
  )
})

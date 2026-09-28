

test_that("add_session_lag calculates days between each client's sessions", {
  data <- data.frame(
    row_id = 1:5,
    client_id = c("a", "b", "a", "b", "a"),
    session_date = as.Date(c(
      "2024-01-01", "2024-02-01", "2024-01-08",
      "2024-02-11", "2024-01-30"
    ))
  )

  result <- add_session_lag(data)

  # split() may reorder rows, so compare in original row order.
  result <- result[order(result$row_id), ]

  expect_identical(result$session_lag, c(NA_real_, NA_real_, 7, 10, 22))
  expect_identical(result$session_date, data$session_date)
})

test_that("add_session_lag requires client_id and session_date", {
  expect_error(add_session_lag(data.frame(client_id = "a")))
  expect_error(add_session_lag(
    data.frame(session_date = as.Date("2024-01-01"))
  ))
})


make_order_data <- function() {
  data.frame(
    row_id = 1:6,
    client_id = c("b", "a", "a", "b", "a", "a"),
    episode_id = c(1, 2, 1, 1, 1, 2),
    episode_session = c(2, 2, 1, 1, 2, 1),
    session_date = as.Date(c(
      "2025-02-08", "2025-03-08", "2025-01-08",
      "2025-02-01", "2025-01-01", "2025-03-01"
    ))
  )
}

test_that("order_sessions sorts by client and date by default", {
  result <- order_sessions(make_order_data())

  expect_identical(result$row_id, c(5L, 3L, 6L, 2L, 4L, 1L))
  expect_identical(rownames(result), as.character(seq_len(6)))
})

test_that("order_sessions can sort by client, episode, and session", {
  result <- order_sessions(make_order_data(), by = "episode")

  expect_identical(result$row_id, c(3L, 5L, 6L, 2L, 4L, 1L))
})

test_that("order_sessions rejects missing sorting values", {
  data <- make_order_data()
  data$session_date[1] <- NA

  expect_error(order_sessions(data), "Missing values detected")

  data <- make_order_data()
  data$episode_session[1] <- NA

  expect_error(
    order_sessions(data, by = "episode"),
    "Missing values detected"
  )
})

test_that("order_sessions validates columns and sorting option", {
  data <- make_order_data()
  data$session_date <- NULL

  expect_error(order_sessions(data))
  expect_error(order_sessions(make_order_data(), by = "unknown"))
})


make_filter_data <- function() {
  data.frame(
    row_id = 1:12,
    client_id = c(rep("a", 7), rep("b", 5)),
    episode_id = c(
      1, 1, 2, 2, 2, 3, 3,
      1, 1, 1, 2, 2
    ),
    episode_session = c(
      1, 2, 1, 2, 3, 1, 2,
      1, 2, 3, 1, 2
    ),
    session_date = as.Date(c(
      "2025-01-01", "2025-01-08",             # a_1: 2 sessions, 1 week
      "2025-02-01", "2025-02-08", "2025-02-15", # a_2: 3 sessions, 2 weeks
      "2025-03-01", "2025-03-22",             # a_3: 2 sessions, 3 weeks
      "2025-01-01", "2025-01-04", "2025-01-08", # b_1: 3 sessions, 1 week
      "2025-02-01", "2025-02-15"              # b_2: 2 sessions, 2 weeks
    )),
    client_episode_id = c(
      rep("a_1", 2), rep("a_2", 3), rep("a_3", 2),
      rep("b_1", 3), rep("b_2", 2)
    )
  )
}

test_that("filter_episodes combines inclusive episode criteria", {
  result <- filter_episodes(
    make_filter_data(),
    min_sessions = 3,
    max_sessions = 3,
    min_weeks = 2,
    max_weeks = 2
  )

  expect_identical(result$row_id, 3:5) # a_2
})

test_that("filter_episodes supports all retention options", {
  data <- make_filter_data()

  matched <- filter_episodes(data, episode_num = 2, min_sessions = 3)
  through <- filter_episodes(
    data, episode_num = 2, min_sessions = 3,
    retain = "through_match"
  )
  client <- filter_episodes(
    data, episode_num = 2, min_sessions = 3,
    retain = "client"
  )

  expect_identical(matched$row_id, 3:5)   # a_2
  expect_identical(through$row_id, 1:5)   # a_1 and a_2
  expect_identical(client$row_id, 1:7)    # All of client a
})

test_that("filter_episodes returns no rows when nothing matches", {
  result <- filter_episodes(make_filter_data(), episode_num = 99)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("filter_episodes validates columns and retain", {
  data <- make_filter_data()
  expect_error(filter_episodes(data, retain = "unknown"))

  data$client_episode_id <- NULL
  expect_error(filter_episodes(data))
})

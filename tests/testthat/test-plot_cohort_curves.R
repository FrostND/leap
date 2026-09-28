
make_cohort_plot_data <- function() {
  data <- data.frame(
    client_id = c(rep("a", 4), rep("b", 4), rep("c", 2), rep("d", 3)),
    episode_id = c(1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 1, 2, 3),
    episode_session = c(1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1, 1),
    outcome = c(10, 14, 12, 18, 8, 10, 7, 11, 5, 9, 1, 2, 3),
    n_episodes = c(rep(2L, 8), rep(1L, 2), rep(3L, 3))
  )

  # Deliberately scramble rows to test session ordering.
  data[c(4, 2, 7, 1, 10, 5, 6, 3, 8, 9, 13, 11, 12), ]
}

test_that("plot_cohort_change calculates episode change and cohort means", {
  plot <- plot_cohort_change(
    make_cohort_plot_data(),
    max_episodes = 2
  )

  expect_s3_class(plot, "ggplot")
  expect_false("d" %in% plot$data$client_id)

  changes <- plot$data[
    order(plot$data$client_id, plot$data$episode_id),
    c("client_id", "episode_id", "change")
  ]
  expect_equal(changes$change, c(4, 6, 2, 4, 4))

  mean_layer <- Filter(
    function(layer) {
      inherits(layer$geom, "GeomLine") &&
        is.data.frame(layer$data)
    },
    plot$layers
  )[[1]]
  means <- mean_layer$data

  two_episode_means <- means[means$n_episodes == 2, ]
  two_episode_means <- two_episode_means[
    order(two_episode_means$episode_id),
  ]

  expect_equal(two_episode_means$n, c(2, 2))
  expect_equal(two_episode_means$mean_change, c(3, 5))
})

test_that("plot_cohort_change draws intervals only for groups with n >= 2", {
  plot <- plot_cohort_change(
    make_cohort_plot_data(),
    max_episodes = 2
  )

  errorbar_layer <- Filter(
    function(layer) inherits(layer$geom, "GeomErrorbar"),
    plot$layers
  )[[1]]
  intervals <- errorbar_layer$data
  intervals <- intervals[order(intervals$episode_id), ]

  expect_true(all(intervals$n_episodes == 2))
  expect_equal(intervals$n, c(2, 2))
  expect_equal(intervals$lower_ci, c(3, 5) - 1.96)
  expect_equal(intervals$upper_ci, c(3, 5) + 1.96)
})

test_that("plot_cohort_change reverses change when lower is better", {
  plot <- plot_cohort_change(
    make_cohort_plot_data(),
    max_episodes = 2,
    higher_is_better = FALSE,
    show_individuals = FALSE
  )

  changes <- plot$data[
    order(plot$data$client_id, plot$data$episode_id),
    "change"
  ]

  expect_equal(changes, c(-4, -6, -2, -4, -4))
  expect_equal(length(plot$layers), 4)
})

test_that("plot_cohort_change omits episodes with missing endpoints", {
  data <- make_cohort_plot_data()
  data$outcome[
    data$client_id == "b" &
      data$episode_id == 1 &
      data$episode_session == 2
  ] <- NA_real_

  plot <- plot_cohort_change(data, max_episodes = 2)

  expect_false(any(
    plot$data$client_id == "b" & plot$data$episode_id == 1
  ))
  expect_true(any(
    plot$data$client_id == "b" & plot$data$episode_id == 2
  ))
})

test_that("plot_cohort_change validates inputs and empty results", {
  data <- make_cohort_plot_data()

  expect_error(
    plot_cohort_change(data, max_episodes = 0),
    "positive whole number"
  )
  expect_error(
    plot_cohort_change(data, y_lims = c(10, 0)),
    "two increasing numbers"
  )

  data$outcome <- NULL
  expect_error(plot_cohort_change(data))
})

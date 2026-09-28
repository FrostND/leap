make_episode_change_data <- function() {
  data.frame(
    client_id = c("a", "a", "b", "b", "c", "d", "d", "d"),
    episode_id = c(1, 2, 1, 2, 1, 1, 2, 3),
    n_episodes = c(2, 2, 2, 2, 1, 3, 3, 3),
    change = c(2, 4, 4, 6, 10, 1, 3, 5),
    client_episode_id = c(
      "a_1", "a_2", "b_1", "b_2", "c_1", "d_1", "d_2", "d_3"
    )
  )
}

get_change_summary <- function(plot) {
  mean_layer <- Filter(
    function(layer) {
      inherits(layer$geom, "GeomLine") &&
        is.data.frame(layer$data)
    },
    plot$layers
  )[[1]]

  mean_layer$data[
    order(mean_layer$data$episode_id),
    ,
    drop = FALSE
  ]
}

test_that("plot_episode_change calculates means by episode", {
  plot <- plot_episode_change(
    make_episode_change_data(),
    max_episodes = 2
  )
  summary <- get_change_summary(plot)

  expect_s3_class(plot, "ggplot")
  expect_equal(summary$episode_id, c(1, 2))
  expect_equal(summary$n, c(4, 3))
  expect_equal(summary$mean_change, c(4.25, 13 / 3))
  expect_false(3 %in% plot$data$episode_id)

  errorbar_layer <- Filter(
    function(layer) inherits(layer$geom, "GeomErrorbar"),
    plot$layers
  )[[1]]
  intervals <- errorbar_layer$data
  first <- intervals[intervals$episode_id == 1, ]

  se <- stats::sd(c(2, 4, 10, 1)) / sqrt(4)
  expect_equal(first$lower_ci, 4.25 - 1.96 * se)
  expect_equal(first$upper_ci, 4.25 + 1.96 * se)
})

test_that("plot_episode_change filters to multiple-episode clients", {
  plot <- plot_episode_change(
    make_episode_change_data(),
    cohort = "multiple",
    max_episodes = 2,
    show_individuals = FALSE
  )
  summary <- get_change_summary(plot)

  expect_false("c" %in% plot$data$client_id)
  expect_equal(summary$n, c(3, 3))
  expect_equal(summary$mean_change, c(7 / 3, 13 / 3))
  expect_equal(length(plot$layers), 4)
})

test_that("plot_episode_change excludes missing changes from summaries", {
  data <- make_episode_change_data()
  data$change[data$client_id == "c"] <- NA_real_

  plot <- plot_episode_change(data)
  summary <- get_change_summary(plot)

  expect_equal(summary$n[summary$episode_id == 1], 3)
  expect_equal(
    summary$mean_change[summary$episode_id == 1],
    7 / 3
  )

  # Episode 3 has one client, so its standard error is undefined.
  expect_true(is.na(
    summary$lower_ci[summary$episode_id == 3]
  ))
})

test_that("plot_episode_change validates options and columns", {
  data <- make_episode_change_data()

  expect_error(plot_episode_change(data, cohort = "unknown"))

  data$change <- NULL
  expect_error(plot_episode_change(data))
})


make_episode_curve_data <- function() {
  data <- expand.grid(
    episode_session = 1:3,
    episode_id = 1:2,
    client_id = c("a", "b"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )

  data$outcome <-
    8 +
    2 * data$episode_session +
    data$episode_id +
    ifelse(data$client_id == "b", 2, 0)

  data
}

test_that("plot_episode_curves draws separate client-episode trajectories", {
  plot <- plot_episode_curves(make_episode_curve_data())

  expect_s3_class(plot, "ggplot")
  expect_equal(length(plot$layers), 3)

  lines <- ggplot2::layer_data(plot, 1)

  expect_equal(nrow(lines), 12)
  expect_equal(
    length(unique(interaction(lines$PANEL, lines$group))),
    4
  )
  expect_equal(length(unique(lines$PANEL)), 2)
})

test_that("plot_episode_curves uses the requested cutoff and y limits", {
  plot <- plot_episode_curves(
    make_episode_curve_data(),
    outcome_limits = c(5, 20),
    clinical_cutoff = 12
  )

  reference_line <- ggplot2::layer_data(plot, 2)

  expect_true(all(reference_line$yintercept == 12))
  expect_equal(plot$coordinates$limits$y, c(5, 20))
  expect_equal(
    plot$scales$get_scales("x")$limits,
    c(1, NA_real_)
  )
})

test_that("plot_episode_curves fits a mean line in each episode panel", {
  plot <- plot_episode_curves(make_episode_curve_data())

  smooth <- ggplot2::layer_data(plot, 3)

  expect_true(nrow(smooth) > 0)
  expect_equal(length(unique(smooth$PANEL)), 2)
})

test_that("plot_episode_curves requires its input columns", {
  data <- make_episode_curve_data()
  data$outcome <- NULL

  expect_error(plot_episode_curves(data))
})

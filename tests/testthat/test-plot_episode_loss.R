make_episode_loss_data <- function() {
  data.frame(
    client_id = c("a", "a", "b"),
    prior_episode = c(1, 2, 1),
    next_episode = c(2, 3, 2),
    prior_discharge = c(16, 18, 12),
    next_intake = c(12, 13, 9),
    days_between = c(30, 60, 120),
    bad_enough_level = c(4, 5, 3)
  )
}

test_that("plot_episode_loss scales break widths by elapsed time", {
  plot <- plot_episode_loss(make_episode_loss_data())

  expect_s3_class(plot, "ggplot")
  expect_equal(
    plot$data$gap_width,
    0.15 + 0.55 * c(30, 60, 120) / 120
  )
  expect_equal(plot$data$x_prior, c(1, 2, 1))
  expect_equal(
    plot$data$x_next,
    plot$data$prior_episode + plot$data$gap_width
  )

  segments <- ggplot2::layer_data(plot, 1)
  expect_equal(nrow(segments), 3)
  expect_equal(segments$y, c(16, 18, 12))
  expect_equal(segments$yend, c(12, 13, 9))
})

test_that("plot_episode_loss can use equal break widths", {
  plot <- plot_episode_loss(
    make_episode_loss_data(),
    show_time = FALSE,
    show_individuals = FALSE,
    y_lims = c(0, 25)
  )

  expect_equal(plot$data$gap_width, rep(0.35, 3))
  expect_equal(length(plot$layers), 2) # Discharge and intake points
  expect_equal(plot$coordinates$limits$y, c(0, 25))
})

test_that("plot_episode_loss restricts displayed transitions", {
  plot <- plot_episode_loss(
    make_episode_loss_data(),
    max_episodes = 2
  )

  expect_equal(nrow(plot$data), 2)
  expect_true(all(plot$data$next_episode == 2))
})

test_that("plot_episode_loss requires its input columns", {
  data <- make_episode_loss_data()
  data$days_between <- NULL

  expect_error(plot_episode_loss(data))
})

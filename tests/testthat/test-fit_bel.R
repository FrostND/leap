make_bel_data <- function() {
  i <- seq_len(96)
  client_number <- rep(seq_len(12), each = 8)
  prior_episode <- rep(rep(1:4, each = 2), times = 12)
  days_between <- 30 + 3 * (i %% 17)
  prior_discharge <- 10 + ((i * 7) %% 19)

  data.frame(
    client_id = sprintf("c%02d", client_number),
    prior_episode = prior_episode,
    days_between = days_between,
    prior_discharge = prior_discharge,
    bad_enough_level =
      2 + 0.03 * days_between + 0.4 * prior_discharge +
      0.5 * prior_episode + client_number / 5 + 0.2 * sin(i)
  )
}

test_that("fit_bel fits a model with centered predictors by default", {
  data <- make_bel_data()
  model <- fit_bel(data)

  expect_s4_class(model, "merMod")
  expect_equal(stats::nobs(model), nrow(data))
  expect_true(all(c(
    "time_c", "prior_discharge_c", "prior_episode_c"
  ) %in% names(stats::model.frame(model))))
  expect_equal(mean(stats::model.frame(model)$time_c), 0, tolerance = 1e-10)
  expect_equal(
    mean(stats::model.frame(model)$prior_discharge_c),
    0,
    tolerance = 1e-10
  )
  expect_identical(
    stats::model.frame(model)$prior_episode_c,
    data$prior_episode - 1
  )
})

test_that("fit_bel can fit with uncentered predictors", {
  model <- fit_bel(make_bel_data(), center = FALSE)
  predictors <- names(stats::model.frame(model))

  expect_s4_class(model, "merMod")
  expect_true(all(c(
    "days_between", "prior_discharge", "prior_episode"
  ) %in% predictors))
  expect_false("time_c" %in% predictors)
})

test_that("fit_bel accepts custom column names", {
  data <- make_bel_data()
  names(data) <- c("person", "episode", "gap", "discharge", "loss")

  model <- fit_bel(
    data,
    bel = "loss",
    time = "gap",
    prior_discharge = "discharge",
    prior_episode = "episode",
    client = "person",
    center = FALSE
  )

  expect_s4_class(model, "merMod")
  expect_equal(stats::nobs(model), nrow(data))
})

test_that("fit_bel omits rows with missing model values", {
  data <- make_bel_data()
  data$bad_enough_level[1] <- NA_real_

  model <- fit_bel(data)

  expect_equal(stats::nobs(model), nrow(data) - 1)
})

test_that("fit_bel requires the specified columns", {
  data <- make_bel_data()
  data$days_between <- NULL

  expect_error(fit_bel(data))
})


make_sao_data <- function() {
  data <- expand.grid(
    episode_id = 1:2,
    client_id = sprintf("c%02d", 1:20),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )

  client_number <- match(data$client_id, sprintf("c%02d", 1:20))
  data <- data[client_number <= 12 | data$episode_id == 1, ]
  client_number <- match(data$client_id, sprintf("c%02d", 1:20))

  data$n_episodes <- ifelse(client_number <= 12, 2L, 1L)
  data$client_episode_id <- paste(
    data$client_id, data$episode_id, sep = "_"
  )
  data$n_sessions <- 5 + ((client_number * 3 + data$episode_id * 2) %% 7)

  data$slope <-
    0.2 +
    0.04 * data$n_sessions +
    0.15 * data$episode_id +
    0.02 * data$n_sessions * data$episode_id +
    0.8 * sin(client_number * 1.7) +
    0.1 * cos(seq_len(nrow(data)) * 2.3)

  rownames(data) <- NULL
  data
}

test_that("fit_sao fits each centered model specification", {
  data <- make_sao_data()

  null <- fit_sao(data, model = "null")
  session <- fit_sao(data, model = "session")
  episode <- fit_sao(data, model = "episode")
  adjusted <- fit_sao(data, model = "adjusted")
  full <- fit_sao(data, model = "full")

  expect_true(all(vapply(
    list(null, session, episode, adjusted, full),
    inherits, logical(1), what = "merMod"
  )))

  expect_named(lme4::fixef(null), "(Intercept)")
  expect_named(lme4::fixef(session), c("(Intercept)", "n_sessions_c"))
  expect_named(lme4::fixef(episode), c("(Intercept)", "episode_c"))
  expect_named(
    lme4::fixef(adjusted),
    c("(Intercept)", "episode_c", "n_sessions_c")
  )
  expect_named(
    lme4::fixef(full),
    c(
      "(Intercept)", "episode_c", "n_sessions_c",
      "episode_c:n_sessions_c"
    )
  )

  frame <- stats::model.frame(full)
  expect_equal(min(frame$episode_c), 0)
  expect_equal(mean(frame$n_sessions_c), 0, tolerance = 1e-10)
})

test_that("fit_sao uses original predictors when center is FALSE", {
  model <- fit_sao(make_sao_data(), center = FALSE, model = "full")

  expect_named(
    lme4::fixef(model),
    c(
      "(Intercept)", "episode_id", "n_sessions",
      "episode_id:n_sessions"
    )
  )
})

test_that("fit_sao restricts the multiple-episode cohort", {
  model <- fit_sao(
    make_sao_data(), cohort = "multiple", model = "null"
  )

  expect_equal(stats::nobs(model), 12 * 2)
})

test_that("fit_sao validates options and required columns", {
  data <- make_sao_data()

  expect_error(fit_sao(data, model = "unknown"))
  expect_error(fit_sao(data, cohort = "unknown"))

  data$slope <- NULL
  expect_error(fit_sao(data))
})

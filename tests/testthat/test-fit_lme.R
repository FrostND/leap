
make_lme_data <- function() {
  data <- expand.grid(
    episode_session = 1:6,
    episode_id = 1:2,
    client_id = sprintf("c%02d", 1:18),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )

  client_number <- match(data$client_id, sprintf("c%02d", 1:18))
  data <- data[client_number <= 12 | data$episode_id == 1, ]
  client_number <- match(data$client_id, sprintf("c%02d", 1:18))

  data$n_episodes <- ifelse(client_number <= 12, 2L, 1L)
  data$client_episode_id <- paste(
    data$client_id, data$episode_id, sep = "_"
  )

  data$outcome <-
    12 +
    0.4 * data$episode_session +
    0.6 * data$episode_id +
    1.5 * sin(client_number * 1.7) +
    0.25 * cos(client_number * 1.3) * data$episode_session +
    0.8 * sin(client_number * 2.1 + data$episode_id * 0.8) +
    0.2 * cos(client_number * 0.7 + data$episode_id * 2) *
    data$episode_session +
    0.15 * sin(seq_len(nrow(data)) * 2.31)

  rownames(data) <- NULL
  data
}

test_that("fit_lme fits the four centered model specifications", {
  data <- make_lme_data()

  null <- fit_lme(data, model = "null")
  session <- fit_lme(data, model = "session")
  episode <- fit_lme(data, model = "episode")
  full <- fit_lme(data, model = "full")

  expect_s4_class(null, "merMod")
  expect_true(all(vapply(
    list(null, session, episode, full),
    stats::nobs,
    integer(1)
  ) == nrow(data)))

  expect_named(lme4::fixef(null), "(Intercept)")
  expect_named(lme4::fixef(session), c("(Intercept)", "ses_c"))
  expect_named(
    lme4::fixef(episode),
    c("(Intercept)", "ses_c", "eps_c")
  )
  expect_named(
    lme4::fixef(full),
    c("(Intercept)", "ses_c", "eps_c", "ses_c:eps_c")
  )

  expect_equal(min(stats::model.frame(full)$ses_c), 0)
  expect_equal(min(stats::model.frame(full)$eps_c), 0)
})

test_that("fit_lme uses original predictors when center is FALSE", {
  model <- fit_lme(make_lme_data(), center = FALSE, model = "full")

  expect_named(
    lme4::fixef(model),
    c(
      "(Intercept)", "episode_session", "episode_id",
      "episode_session:episode_id"
    )
  )
})

test_that("fit_lme restricts the multiple-episode cohort", {
  data <- make_lme_data()

  model <- fit_lme(data, cohort = "multiple", model = "null")

  expect_equal(stats::nobs(model), 12 * 2 * 6)
})

test_that("fit_lme validates model options and required columns", {
  data <- make_lme_data()

  expect_error(fit_lme(data, model = "unknown"))
  expect_error(fit_lme(data, cohort = "unknown"))

  data$episode_session <- NULL
  expect_error(fit_lme(data))
})

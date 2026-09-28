
make_brms_data <- function() {
  data <- expand.grid(
    episode_session = 1:3,
    episode_id = 1:2,
    client_id = c("a", "b", "c"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )

  data <- data[
    data$client_id != "c" | data$episode_id == 1,
  ]
  data$n_episodes <- ifelse(data$client_id == "c", 1L, 2L)
  data$outcome <- seq_len(nrow(data))
  rownames(data) <- NULL
  data
}

test_that("fit_brms passes centered formula, data, and options to brms", {
  local_mocked_bindings(
    brm_fit = function(formula, data, family, ...) {
      list(formula = formula, data = data, family = family, options = list(...))
    }
  )

  result <- fit_brms(
    make_brms_data(),
    cohort = "multiple",
    model = "full",
    chains = 2,
    iter = 500
  )

  expect_equal(nrow(result$data), 12)
  expect_equal(min(result$data$ses_c), 0)
  expect_equal(min(result$data$eps_c), 0)
  expect_identical(
    attr(terms(lme4::nobars(result$formula)), "term.labels"),
    c("ses_c", "eps_c", "ses_c:eps_c")
  )
  expect_identical(result$family$family, "gaussian")
  expect_identical(result$options, list(chains = 2, iter = 500))
})

test_that("fit_brms uses original predictors when center is FALSE", {
  local_mocked_bindings(
    brm_fit = function(formula, data, family, ...) {
      list(formula = formula, data = data)
    }
  )

  result <- fit_brms(
    make_brms_data(), center = FALSE, model = "session"
  )

  expect_identical(
    attr(terms(lme4::nobars(result$formula)), "term.labels"),
    "episode_session"
  )
  expect_false("ses_c" %in% names(result$data))
})

test_that("fit_brms validates options and required columns", {
  data <- make_brms_data()

  expect_error(fit_brms(data, model = "unknown"))
  expect_error(fit_brms(data, cohort = "unknown"))

  data$outcome <- NULL
  expect_error(fit_brms(data))
})

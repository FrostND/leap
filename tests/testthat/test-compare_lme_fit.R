
test_that("compare_lme_fit summarizes named lmer models", {
  intercept <- lme4::lmer(
    Reaction ~ Days + (1 | Subject),
    data = lme4::sleepstudy,
    REML = FALSE
  )
  slope <- lme4::lmer(
    Reaction ~ Days + (Days | Subject),
    data = lme4::sleepstudy,
    REML = FALSE
  )

  result <- compare_lme_fit(list(intercept = intercept, slope = slope))

  expect_identical(result$model, c("intercept", "slope"))
  expect_equal(result$n_obs, c(180, 180))
  expect_equal(result$n_par, c(4, 6))
  expect_true(all(is.finite(result$logLik)))
  expect_true(all(is.finite(result$AIC)))
  expect_true(all(is.finite(result$BIC)))
  expect_true(all(!result$REML))
  expect_identical(result$convergence, c("OK", "OK"))
  expect_true(all(is.na(result$message)))
})

test_that("compare_lme_fit names unnamed models", {
  model <- lme4::lmer(
    Reaction ~ Days + (1 | Subject),
    data = lme4::sleepstudy
  )

  result <- compare_lme_fit(list(model))

  expect_identical(result$model, "model_1")
  expect_true(result$REML)
})

test_that("compare_lme_fit reports convergence messages", {
  model <- lme4::lmer(
    Reaction ~ Days + (1 | Subject),
    data = lme4::sleepstudy
  )

  # Supply messages directly to test the reporting branch.
  model@optinfo$conv$lme4$messages <- c(
    "gradient issue", "Hessian issue"
  )

  result <- compare_lme_fit(list(model))

  expect_identical(result$convergence, "Warning")
  expect_identical(result$message, "gradient issue; Hessian issue")
})

test_that("compare_lme_fit rejects invalid inputs", {
  expect_error(compare_lme_fit("not a list"), "must be a list")
  expect_error(
    compare_lme_fit(list(valid = 1, invalid = lm(mpg ~ wt, data = mtcars))),
    "must inherit from class `merMod`"
  )
})

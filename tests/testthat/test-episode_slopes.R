# test-estimate_episode_slopes.R

# Output structure  -------------------------------------------------

test_that("estimate_episode_slopes returns expected structure", {
  expect_warning(
    out <- estimate_episode_slopes(test_data),
    "four or fewer sessions"
  )

  expect_s3_class(out, "data.frame")

  expect_equal(nrow(out), 3)

  expect_named(
    out,
    c(
      "client_id",
      "episode_id",
      "n_sessions",
      "n_episodes",
      "pre",
      "post",
      "change",
      "slope"
    )
  )
})


# -------------------------------------------------------------------------
# Episode identifiers and counts
# -------------------------------------------------------------------------

test_that("estimate_episode_slopes identifies episodes correctly", {
  expect_warning(
    out <- estimate_episode_slopes(test_data),
    "four or fewer sessions"
  )

  expect_equal(out$client_id, c("A", "A", "B"))

  expect_equal(out$episode_id, c(1, 2, 1))

  expect_equal(out$n_sessions, c(3, 3, 3))

  expect_equal(out$n_episodes, c(2, 2, 1))
})


# -------------------------------------------------------------------------
# Pre-post values
# -------------------------------------------------------------------------

test_that("estimate_episode_slopes returns correct pre-post scores", {
  expect_warning(
    out <- estimate_episode_slopes(test_data),
    "four or fewer sessions"
  )

  expect_equal(
    out$pre,
    c(10, 8, 12)
  )

  expect_equal(
    out$post,
    c(12, 12, 10)
  )
})


# -------------------------------------------------------------------------
# Change scores
# -------------------------------------------------------------------------

test_that("estimate_episode_slopes calculates correct change scores", {
  expect_warning(
    out <- estimate_episode_slopes(
      test_data,
      higher_is_better = TRUE
    ),
    "four or fewer sessions"
  )

  expect_equal(
    out$change,
    c(2, 4, -2)
  )
})


# -------------------------------------------------------------------------
# Slopes
# -------------------------------------------------------------------------

test_that("estimate_episode_slopes estimates correct linear slopes", {
  expect_warning(
    out <- estimate_episode_slopes(
      test_data,
      higher_is_better = TRUE
    ),
    "four or fewer sessions"
  )

  expect_equal(
    out$slope,
    c(1, 2, -1),
    tolerance = 1e-5
  )
})


# -------------------------------------------------------------------------
# Outcome direction
# -------------------------------------------------------------------------

test_that("higher_is_better reverses change and slope direction", {
  expect_warning(
    out <- estimate_episode_slopes(
      test_data,
      higher_is_better = FALSE
    ),
    "four or fewer sessions"
  )

  expect_equal(
    out$change,
    c(-2, -4, 2)
  )

  expect_equal(
    out$slope,
    c(-1, -2, 1),
    tolerance = 1e-5
  )

  # Raw pre-post scores should not be altered.
  expect_equal(
    out$pre,
    c(10, 8, 12)
  )

  expect_equal(
    out$post,
    c(12, 12, 10)
  )
})


# -------------------------------------------------------------------------
# Short episodes
# -------------------------------------------------------------------------

test_that("estimate_episode_slopes warns about short episodes", {
  expect_warning(
    estimate_episode_slopes(test_data),
    "four or fewer sessions"
  )
})


#-------------------------------------------------------------------------
# Missing required columns
#-------------------------------------------------------------------------

test_that("estimate_episode_slopes fails when required columns are missing", {
  bad_data <- test_data
  bad_data$outcome <- NULL

  expect_error(
    estimate_episode_slopes(bad_data),
    "outcome"
  )
})

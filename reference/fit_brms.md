# Fit a Bayesian longitudinal mixed-effects model

Fits a Bayesian multilevel model for session-level outcomes across
repeated treatment episodes. Models can estimate within-episode change,
differences across successive treatment episodes, and whether rates of
within-episode change vary across episodes.

## Usage

``` r
fit_brms(
  data,
  center = TRUE,
  cohort = c("all", "multiple"),
  model = c("null", "session", "episode", "full"),
  ...
)
```

## Arguments

- data:

  A data frame containing session-level treatment records. The data must
  contain `client_id`, `episode_id`, `episode_session`, and `outcome`.

- center:

  Logical indicating whether predictors should be centered prior to
  model estimation. When `TRUE`, `episode_session` is centered at the
  first session and `episode_id` is centered at the first treatment
  episode. Defaults to `TRUE`.

- cohort:

  Character string specifying the client cohort to analyze. Must be one
  of `"all"` or `"multiple"`. Defaults to `"all"`.

- model:

  Character string specifying the model to fit. Must be one of `"null"`,
  `"session"`, `"episode"`, or `"full"`. Defaults to `"null"`.

- ...:

  Additional arguments passed to
  [`brms::brm()`](https://paulbuerkner.com/brms/reference/brm.html),
  such as `prior`, `chains`, `iter`, `warmup`, `cores`, or `seed`.

## Value

A fitted `brmsfit` object returned by
[`brms::brm()`](https://paulbuerkner.com/brms/reference/brm.html).

## Details

`fit_brms()` provides a Bayesian counterpart to
[`fit_lme()`](https://frostnd.github.io/leap/reference/fit_lme.md) for
modeling session-level change across repeated treatment episodes.
Treatment episodes are nested within clients, and models containing a
session effect allow within-episode trajectories to vary across the
grouping structure.

Four model specifications are available:

- `"null"`:

  Fits an unconditional random-intercept model containing no session- or
  episode-level predictors.

- `"session"`:

  Adds session within episode as a predictor of the outcome and allows
  session trajectories to vary across the grouping structure.

- `"episode"`:

  Adds treatment episode number to the session model, allowing average
  outcome levels to differ across successive episodes.

- `"full"`:

  Includes session within episode, treatment episode number, and their
  interaction, allowing rates of within-episode change to differ across
  successive treatment episodes.

The full model can be expressed as:

\$\$ Y\_{ijk} = \beta_0 + \beta_1(\mathrm{Session}\_{ijk}) +
\beta_2(\mathrm{Episode}\_{ij}) + \beta_3(\mathrm{Session}\_{ijk} \times
\mathrm{Episode}\_{ij}) + \mathrm{random\\ effects} + \varepsilon\_{ijk}
\$\$

where session \\k\\ occurs within episode \\j\\, which is nested within
client \\i\\.

When `center = TRUE`, session number and episode number are recoded so
that Session 1 and Episode 1 equal zero. Consequently, the intercept
represents the expected outcome at the first session of the first
treatment episode. In the full model, the session coefficient represents
the expected rate of change during Episode 1, while the
session-by-episode interaction represents change in the session
trajectory across successive treatment episodes.

Additional arguments are passed directly to
[`brms::brm()`](https://paulbuerkner.com/brms/reference/brm.html). This
allows users to specify priors and sampling options without changing the
model structure defined by `fit_brms()`.

## See also

[`fit_lme()`](https://frostnd.github.io/leap/reference/fit_lme.md),
[`brms::brm()`](https://paulbuerkner.com/brms/reference/brm.html)

## Examples

``` r
if (FALSE) { # \dontrun{
# Fit the unconditional model
m0 <- fit_brms(
  data = treatment_data,
  model = "null"
)

# Model within-episode change
m1 <- fit_brms(
  data = treatment_data,
  model = "session"
)

# Fit the full episode model
m2 <- fit_brms(
  data = treatment_data,
  cohort = "multiple",
  model = "full",
  chains = 4,
  iter = 2000,
  seed = 1234
)

summary(m2)
} # }
```

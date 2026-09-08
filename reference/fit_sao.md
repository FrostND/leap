# Fit a slopes-as-outcomes model

Fits a multilevel slopes-as-outcomes (SAO) model in which
episode-specific rates of change are treated as the dependent variable.
The function operates on episode-level data produced by
[`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md)
and models variation in treatment response across clients and treatment
episodes.

## Usage

``` r
fit_sao(
  data,
  center = TRUE,
  cohort = c("all", "multiple"),
  model = c("null", "session", "episode", "adjusted", "full")
)
```

## Arguments

- data:

  A data frame of episode-level slope estimates produced by
  [`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md).
  The data must contain `client_id`, `episode_id`, `n_sessions`, and
  `slope`.

- center:

  Logical indicating whether predictors should be centered prior to
  model estimation. When `TRUE`, `episode_id` is centered at the first
  treatment episode and `n_sessions` is centered at its sample mean.
  Defaults to `TRUE`.

- model:

  Character string specifying the model to fit. Must be one of `"null"`,
  `"session"`, `"episode"`, `"adjusted"`, or `"full"`. Defaults to
  `"null"`.

## Value

A fitted `lmerMod` object returned by
[`lme4::lmer()`](https://rdrr.io/pkg/lme4/man/lmer.html).

## Details

`fit_sao()` represents the second stage of a slopes-as-outcomes
analysis. Episode-specific rates of change must first be estimated using
[`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md).
Each row of the resulting data represents one treatment episode, with
repeated episodes nested within clients.

Five model specifications are available:

- `"null"`:

  Fits an unconditional random-intercept model containing no
  episode-level predictors.

- `"session"`:

  Adds the number of sessions within the treatment episode as a
  predictor of the episode-specific slope.

- `"episode"`:

  Adds treatment episode number as a predictor of the episode-specific
  slope.

- `"adjusted"`:

  Includes both treatment episode number and number of sessions as
  additive predictors.

- `"full"`:

  Includes treatment episode number, number of sessions, and their
  interaction.

The full model can be expressed as:

\$\$ \mathrm{Slope}\_{ij} = \beta_0 + \beta_1(\mathrm{Episode}\_{ij}) +
\beta_2(\mathrm{Sessions}\_{ij}) + \beta_3(\mathrm{Episode}\_{ij} \times
\mathrm{Sessions}\_{ij}) + u\_{0i} + \varepsilon\_{ij} \$\$

where episode \\j\\ is nested within client \\i\\, and \\u_0i\\
represents a client-specific random intercept.

When `center = TRUE`, treatment episode number is centered at the first
episode (`episode_id - 1`) and number of sessions is grand-mean
centered. Consequently, the intercept represents the expected treatment
slope during the first treatment episode for an episode of average
length. Centering does not affect the fit of a given model but changes
the interpretation of its intercept and, for models containing
interactions, its lower-order coefficients.

Positive slope values represent improvement when the input to
[`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md)
was constructed so that higher slope values indicate improvement.

## See also

[`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md),
[`compare_lme_fit()`](https://frostnd.github.io/leap/reference/compare_lme_fit.md),
[`fit_lme()`](https://frostnd.github.io/leap/reference/fit_lme.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Estimate one slope for each client treatment episode
slopes <- episode_slopes(treatment_data)

# Fit the unconditional model
m0 <- fit_sao(data = slopes, model = "null")

# Add treatment episode number
m1 <- fit_sao(data = slopes, model = "episode")

# Fit the full model
m2 <- fit_sao(data = slopes, model = "full")

summary(m2)
} # }
```

# Compare mixed-effects model fit

Compares a set of fitted mixed-effects models using common model-fit and
diagnostic statistics. The function summarizes sample size, parameter
count, log-likelihood, information criteria, estimation method,
singularity, and convergence status for each model.

## Usage

``` r
compare_lme_fit(models)
```

## Arguments

- models:

  A named or unnamed list of fitted mixed-effects models that inherit
  from class `"merMod"`, such as models returned by
  [`lme4::lmer()`](https://rdrr.io/pkg/lme4/man/lmer.html). If the list
  is unnamed, model names are generated automatically.

## Value

A data frame with one row per model and the following variables:

- model:

  Model name.

- n_obs:

  Number of observations used to fit the model.

- n_par:

  Number of estimated model parameters.

- logLik:

  Model log-likelihood.

- AIC:

  Akaike information criterion.

- BIC:

  Bayesian information criterion.

- REML:

  Logical indicator of whether the model was estimated using restricted
  maximum likelihood.

- singular:

  Logical indicator of whether the fitted model is singular.

- convergence:

  Character indicator of model convergence status.

- message:

  Convergence warning returned by `lme4`, if present.

## Details

The function is intended to provide a compact comparison of alternative
mixed-effects model specifications. Lower AIC and BIC values generally
indicate better relative fit among models estimated on the same data.

Singularity is evaluated using
[`lme4::isSingular()`](https://rdrr.io/pkg/lme4/man/isSingular.html)
with a tolerance of `1e-4`. Convergence warnings are extracted from the
model's optimizer information and reported in the returned data frame.

Models with different fixed-effects specifications should generally be
compared using maximum likelihood rather than restricted maximum
likelihood. Users should therefore consider fitting such models with
`REML = FALSE` before comparing likelihood-based fit statistics.

## See also

[`lme4::lmer()`](https://rdrr.io/pkg/lme4/man/lmer.html),
[`lme4::isSingular()`](https://rdrr.io/pkg/lme4/man/isSingular.html)

## Examples

``` r
if (FALSE) { # \dontrun{
models <- list(
  random_intercept = mod_1,
  episode_intercept = mod_2,
  random_slope = mod_3
)

compare_lme_fit(models)
} # }
```

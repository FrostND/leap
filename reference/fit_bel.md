# Fit a bad-enough-level model

Fits a linear mixed-effects model predicting deterioration between
consecutive treatment episodes from the time elapsed between episodes,
the outcome score at the end of the prior episode, and the ordinal
number of the prior episode.

## Usage

``` r
fit_bel(
  data,
  bel = "bad_enough_level",
  time = "days_between",
  prior_discharge = "prior_discharge",
  prior_episode = "prior_episode",
  client = "client_id",
  center = TRUE
)
```

## Arguments

- data:

  A transition-level data frame produced by
  [`episode_breaks()`](https://frostnd.github.io/leap/reference/episode_breaks.md).

- bel:

  Character string specifying the bad-enough-level outcome column.
  Defaults to `"bad_enough_level"`.

- time:

  Character string specifying the between-episode interval variable.
  Defaults to `"days_between"`.

- prior_discharge:

  Character string specifying the prior episode's discharge outcome
  column. Defaults to `"prior_discharge"`.

- prior_episode:

  Character string specifying the prior episode number column. Defaults
  to `"prior_episode"`.

- client:

  Character string specifying the client identifier column. Defaults to
  `"client_id"`.

- center:

  Logical indicating whether continuous predictors should be grand-mean
  centered. Defaults to `TRUE`.

## Value

A fitted `lmerMod` object.

## Details

This function is intended for transition-level data returned by
[`episode_breaks()`](https://frostnd.github.io/leap/reference/episode_breaks.md).

The fitted model is:

\$\$ \mathrm{BEL}\_{ij} = \beta_0 + \beta_1(\mathrm{Time}\_{ij}) +
\beta_2(\mathrm{PriorDischarge}\_{ij}) +
\beta_3(\mathrm{PriorEpisode}\_{ij}) + u\_{0i} + \varepsilon\_{ij} \$\$

where transitions are nested within clients. The random intercept
accounts for stable between-client differences in the tendency to
deteriorate between treatment episodes.

When `center = TRUE`, the time interval and prior discharge score are
grand-mean centered. The prior episode number is shifted so that Episode
1 is coded as zero. The intercept therefore represents expected
between-episode deterioration following Episode 1 for a client with
average prior discharge and average time between episodes.

## See also

[`episode_breaks()`](https://frostnd.github.io/leap/reference/episode_breaks.md)

## Examples

``` r
if (FALSE) { # \dontrun{
transition_data <- episode_breaks(treatment_data)

model <- fit_bel(transition_data)
summary(model)
} # }
```

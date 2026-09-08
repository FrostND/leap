# Plot treatment episode trajectories

Visualizes session-level outcome trajectories across successive
treatment episodes. Individual client-episode trajectories are shown in
the background, with a pooled linear trend superimposed within each
treatment episode number.

## Usage

``` r
plot_episode_curves(data, outcome_limits = c(0, 25), clinical_cutoff = 10)
```

## Arguments

- data:

  A data frame containing session-level treatment records. The data must
  contain `client_id`, `episode_id`, `episode_session`, and `outcome`.

- outcome_limits:

  Numeric vector of length two specifying the displayed y-axis limits.
  Defaults to `c(0, 25)`.

- clinical_cutoff:

  Optional numeric value specifying a clinical reference threshold to
  display as a horizontal dashed line. Defaults to `10`. Set to `NULL`
  to omit the reference line.

## Value

A ggplot2 object displaying individual client-episode trajectories and
pooled linear trends across treatment episodes.

## Details

`plot_episode_curves()` operates on session-level data in which
treatment episodes have already been identified. Each panel represents a
treatment episode number, such that the Episode 2 panel contains
observations from clients who contributed a second treatment episode.

Individual lines connect observations within each client-specific
treatment episode. The superimposed solid line is estimated using a
simple linear regression of `outcome` on `episode_session` across all
observations contributing to that episode number. It therefore
represents a pooled descriptive trajectory rather than a multilevel
model estimate.

Because clients may attend different numbers of treatment episodes, the
composition of the sample may differ across panels. Apparent differences
between episode-specific trends should therefore be interpreted
descriptively and not as adjusted within-client effects.

The plot is intended primarily for exploratory data analysis and visual
assessment of within-episode change prior to fitting formal longitudinal
models such as
[`fit_lme()`](https://frostnd.github.io/leap/reference/fit_lme.md) or
[`fit_brms()`](https://frostnd.github.io/leap/reference/fit_brms.md).

## See also

[`add_episode_vars()`](https://frostnd.github.io/leap/reference/add_episode_vars.md),
[`plot_episode_change()`](https://frostnd.github.io/leap/reference/plot_episode_change.md),
[`fit_lme()`](https://frostnd.github.io/leap/reference/fit_lme.md),
[`fit_brms()`](https://frostnd.github.io/leap/reference/fit_brms.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Prepare treatment episode variables
df <- add_episode_vars(raw_data)

# Plot session-level trajectories across treatment episodes
plot_episode_curves(df)

# Change the displayed outcome range
plot_episode_curves(df, outcome_limits = c(0, 20))

# Add a different clinical reference threshold
plot_episode_curves(df, clinical_cutoff = 8)

# Omit the clinical reference line
plot_episode_curves(df, clinical_cutoff = NULL)
} # }
```

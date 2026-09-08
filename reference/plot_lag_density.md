# Visualize the distribution of between-session gaps and evaluate candidate episode delimiters.

Displays a kernel density estimate of the number of days between
consecutive treatment sessions. The plot can be used to inspect the
empirical distribution of session gaps and evaluate potential thresholds
for delimiting treatment episodes.

## Usage

``` r
plot_lag_density(data, delimiter = NULL, smooth = 1.5)
```

## Arguments

- data:

  A data frame containing session-level treatment records.

- delimiter:

  Optional numeric value indicating a proposed episode delimiter in
  days. When supplied, a vertical dashed line is added at the specified
  value. Defaults to `NULL`.

- smooth:

  Numeric smoothing multiplier passed to the `adjust` argument of
  [`ggplot2::geom_density()`](https://ggplot2.tidyverse.org/reference/geom_density.html).
  Values greater than `1` produce a smoother density estimate, whereas
  values less than `1` reveal more local variation. Defaults to `1.5`.

- lag:

  Character string specifying the session-lag variable. Defaults to
  `"session_lag"`.

## Value

A `ggplot` object displaying the density of positive between-session
gaps.

## Details

Observations with missing session lags or session lags less than or
equal to zero are excluded before plotting.

The function is intended primarily as an exploratory tool for evaluating
potential episode boundaries. A proposed delimiter can be displayed
using the `delimiter` argument to compare an operational threshold with
the observed distribution of session gaps.

The amount of smoothing can be controlled with `smooth`. Because
between-session gaps are often right-skewed, modest additional smoothing
may help reveal broad distributional patterns. Excessive smoothing,
however, may obscure distinct gap regimes or multimodality.

## See also

[`add_session_lag()`](https://frostnd.github.io/leap/reference/add_session_lag.md),
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Plot the distribution of session gaps
plot_breaks_density(data)

# Display a proposed 90-day episode delimiter
plot_break_density(data, delimiter = 90)

# Increase density smoothing
plot_breaks_density(data, delimiter = 90, smooth = 2)
} # }
```

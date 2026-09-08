# Plot change across treatment episodes

Plots episode-level change scores across successive treatment episodes.
Individual client profiles may be displayed in the background, while
mean change scores and 95% confidence intervals for each episode number
are displayed in the foreground.

## Usage

``` r
plot_episode_change(
  data,
  cohort = c("all", "multiple"),
  max_episodes = NULL,
  show_individuals = TRUE,
  y_lims = NULL
)
```

## Arguments

- data:

  A data frame containing episode-level summaries produced by
  [`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md).
  The data must contain `client_id`, `episode_id`, `n_episodes`, and
  `change`.

- cohort:

  Character string specifying the client cohort to display. Must be one
  of `"all"` or `"multiple"`. `"all"` includes all clients, whereas
  `"multiple"` restricts the plot to clients with more than one
  treatment episode. Defaults to `"all"`.

- max_episodes:

  Optional numeric value specifying the highest treatment episode to
  display. For example, `max_episodes = 3` displays Episodes 1
  through 3. Clients with additional episodes may still contribute
  observations from earlier episodes. Defaults to `NULL`.

- show_individuals:

  Logical indicating whether individual client change profiles and
  observations should be displayed. Defaults to `TRUE`.

- y_lims:

  Optional numeric vector of length two specifying the displayed y-axis
  limits. Defaults to `NULL`.

## Value

A `ggplot` object showing change scores across treatment episodes.

## Details

`plot_episode_change()` operates on episode-level data produced by
[`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md).
Each row represents one treatment episode for a client, and `change`
represents the difference between the first and final outcome
observations within that episode.

The direction of change is determined when
[`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md)
is called. When episode slopes are calculated with
`higher_is_better = TRUE`, positive change scores indicate improvement.
When `higher_is_better = FALSE`, the direction of change is reversed so
that positive values continue to represent improvement.

For each treatment episode number, the function calculates the mean
change score and an approximate 95% confidence interval:

\$\$ \overline{\mathrm{Change}}\_j \mathbin{\pm} 1.96 \times
\mathrm{SE}\_j \$\$

where \\j\\ denotes treatment episode number.

When `show_individuals = TRUE`, observations from the same client are
connected across episodes to show within-client patterns of change.

The composition of the sample may differ across episode numbers because
only clients who return for additional treatment contribute observations
to later episodes. Consequently, differences across episode numbers
should not necessarily be interpreted as within-client change.

## See also

[`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md),
[`plot_episode_curves()`](https://frostnd.github.io/leap/reference/plot_episode_curves.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Calculate episode-level slopes and change scores
episodes <- episode_slopes(treatment_data)

# Plot change across all treatment episodes
plot_episode_change(data = episodes)

# Restrict to clients with multiple treatment episodes
plot_episode_change(data = episodes, cohort = "multiple")

# Display only the first three treatment episodes
plot_episode_change(data = episodes, cohort = "multiple", max_episodes = 3)

# Hide individual client profiles
plot_episode_change(data = episodes, show_individuals = FALSE)

# Reverse the direction of change for an outcome where lower is better
episodes <- episode_slopes(treatment_data, higher_is_better = FALSE)

plot_episode_change(episodes)
} # }
```

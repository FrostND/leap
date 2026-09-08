# Plot growth curves by treatment-episode cohort

Creates a multi-panel figure showing average linear outcome trajectories
for clients grouped according to the total number of treatment episodes
attended. Separate plots are produced for one-, two-, and three-episode
cohorts, and treatment episodes are displayed as facets within each
cohort.

## Usage

``` r
plot_cohort_curves(
  data,
  x_range = NULL,
  y_range = NULL,
  clinical_cutoff = NULL
)
```

## Arguments

- clinical_cutoff:

  Optional numeric value indicating a clinically meaningful outcome
  threshold. When supplied, a dashed horizontal line is added to each
  panel.

- df:

  A data frame containing longitudinal treatment-session records.

- episode_count:

  Character string specifying the column containing the total number of
  episodes attended by each client. Defaults to `"n_episodes"`.

- outcome:

  Character string specifying the outcome variable. Defaults to
  `"outcome"`.

- episode_id:

  Character string specifying the treatment-episode identifier. Defaults
  to `"episode_id"`.

- episode_session:

  Character string specifying session number within treatment episode.
  Defaults to `"episode_session"`.

- x_lims:

  Optional numeric vector of length two defining the displayed x-axis
  limits.

- y_lims:

  Optional numeric vector of length two defining the displayed y-axis
  limits.

## Value

A `patchwork` object containing cohort-specific episode growth curves.

## Details

The resulting cohort plots are arranged in a staggered grid using
patchwork. An optional horizontal reference line may be added to
indicate a clinically meaningful outcome cutoff.

Clients with more than three treatment episodes are excluded. Within
each cohort, separate linear trajectories are estimated for each episode
using `ggplot2::geom_smooth(method = "lm")`.

The fitted lines are extended across the displayed x-axis range using
`fullrange = TRUE`. The figure uses a common y-axis and a staggered
layout in which cohorts with more episodes occupy more horizontal space.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_cohort_curves(
  df = treatment_data,
  episode_count = "n_episodes",
  outcome = "outcome",
  episode_id = "episode_id",
  episode_session = "episode_session",
  x_range = c(1, 30),
  y_range = c(0, 25),
  clinical_cutoff = 12
)
} # }
```

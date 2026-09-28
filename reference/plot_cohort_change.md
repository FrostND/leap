# Plot outcome change across treatment episode cohorts

Plots intake-to-discharge outcome change for clients grouped by their
total number of treatment episodes. Within each cohort, the plot shows
mean change for each episode and, optionally, individual client
trajectories.

## Usage

``` r
plot_cohort_change(
  data,
  max_episodes = 3,
  higher_is_better = TRUE,
  show_individuals = TRUE,
  y_lims = NULL
)
```

## Arguments

- data:

  A session-level data frame containing `client_id`, `episode_id`,
  `episode_session`, `outcome`, and `n_episodes`.

- max_episodes:

  Maximum number of episodes in a cohort to display. Defaults to 3.

- higher_is_better:

  If `TRUE`, change is discharge minus intake. If `FALSE`, change is
  intake minus discharge. Positive values therefore indicate improvement
  in either case.

- show_individuals:

  If `TRUE`, show individual change scores and lines.

- y_lims:

  Optional numeric vector of length two specifying the displayed y-axis
  limits.

## Value

A `ggplot2` plot.

## Details

Intake and discharge are taken from the first and last `episode_session`
within each client episode. Episodes with a missing intake or discharge
outcome are omitted. Error bars show the mean plus or minus 1.96
standard errors; they are omitted when a cohort–episode group has fewer
than two usable clients.

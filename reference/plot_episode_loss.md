# Plot change between treatment episodes

Visualizes changes in outcome scores between the end of one treatment
episode and the beginning of the next. Each line connects a client's
discharge score from one episode with their intake score at the
subsequent episode. Horizontal spacing may be scaled to reflect the
amount of time elapsed between episodes.

## Usage

``` r
plot_episode_loss(
  data,
  max_episodes = NULL,
  show_individuals = TRUE,
  show_time = TRUE,
  y_lims = NULL
)
```

## Arguments

- data:

  A data frame containing between-episode summaries produced by
  [`episode_breaks()`](https://frostnd.github.io/leap/reference/episode_breaks.md).
  The data must contain `client_id`, `prior_episode`, `next_episode`,
  `prior_discharge`, `next_intake`, `days_between`, and
  `bad_enough_level`.

- max_episodes:

  Optional numeric value specifying the highest treatment episode to
  display. For example, `max_episodes = 3` retains transitions ending at
  Episodes 2 and 3. Defaults to `NULL`.

- show_individuals:

  Logical indicating whether individual between-episode transitions
  should be displayed. Defaults to `TRUE`.

- show_time:

  Logical indicating whether horizontal spacing between discharge and
  subsequent intake observations should reflect elapsed time between
  treatment episodes. Defaults to `TRUE`.

- y_lims:

  Optional numeric vector of length two specifying the displayed y-axis
  limits. Defaults to `NULL`.

## Value

A `ggplot` object showing outcome change between successive treatment
episodes.

## Details

`plot_episode_breaks()` operates on transition-level data produced by
[`episode_breaks()`](https://frostnd.github.io/leap/reference/episode_breaks.md).
Each row represents the interval between two consecutive treatment
episodes for a client.

For each transition, the plot connects the outcome score observed at
discharge from the prior episode with the outcome score observed at
intake to the subsequent episode. These transitions provide a visual
representation of between-episode change:

\$\$ \mathrm{Break}\_{ij} = Y\_{ij,\mathrm{discharge}} -
Y\_{i,j+1,\mathrm{intake}} \$\$

when higher outcome scores indicate better functioning. The direction of
this quantity is determined upstream by
[`episode_breaks()`](https://frostnd.github.io/leap/reference/episode_breaks.md),
such that positive values of `bad_enough_level` represent deterioration
between treatment episodes.

When `show_time = TRUE`, the horizontal distance between discharge and
subsequent intake is scaled according to `days_between`. This provides a
visual indication of the relative amount of time separating treatment
episodes while preventing unusually long intervals from dominating the
horizontal scale. Horizontal distance should therefore be interpreted as
relative rather than as a literal calendar-time axis.

When `show_time = FALSE`, a common horizontal distance is used for all
transitions, emphasizing the magnitude and direction of between-episode
change rather than the duration of the treatment break.

Only clients with two or more treatment episodes can contribute
between-episode transitions. Consequently, unlike functions that operate
on session- or episode-level data, a separate client cohort restriction
is not required.

## See also

[`episode_breaks()`](https://frostnd.github.io/leap/reference/episode_breaks.md),
[`plot_episode_change()`](https://frostnd.github.io/leap/reference/plot_episode_change.md),
[`plot_episode_curves()`](https://frostnd.github.io/leap/reference/plot_episode_curves.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Calculate between-episode change
breaks <- episode_breaks(treatment_data)

# Plot between-episode transitions
plot_episode_breaks(data = breaks)

# Use equal spacing between treatment episodes
plot_episode_breaks(data = breaks, show_time = FALSE)

# Display transitions involving only the first three episodes
plot_episode_breaks(data = breaks, max_episodes = 3)

# Hide individual transitions
plot_episode_breaks(data = breaks, show_individuals = FALSE)
} # }
```

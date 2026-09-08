# Build an episode-transition dataset

Converts session-level treatment data into an episode-transition dataset
containing one row for each pair of consecutive treatment episodes
within a client. The resulting data describe changes from the end of one
episode to the beginning of the next episode.

## Usage

``` r
episode_breaks(data, higher_is_better = TRUE)
```

## Arguments

- data:

  A data frame containing longitudinal treatment-session records.

- higher_is_better:

  Logical indicating the direction of favorable outcomes. When `TRUE`,
  positive values of `bad_enough_level` indicate that the client's
  outcome declined between the prior episode's discharge and the next
  episode's intake. When `FALSE`, the score difference is reversed so
  that positive values continue to indicate deterioration. Defaults to
  `TRUE`.

- client:

  Character string specifying the client identifier column. Defaults to
  `"client_id"`.

- episode:

  Character string specifying the treatment episode identifier column.
  Defaults to `"episode_id"`.

- episode_session:

  Character string specifying the session-within-episode column.
  Defaults to `"episode_session"`.

- date:

  Character string specifying the session date column. The column should
  inherit from class `Date`. Defaults to `"session_date"`.

- outcome:

  Character string specifying the outcome variable. Defaults to
  `"outcome"`.

## Value

A data frame containing one row per transition between consecutive
treatment episodes. The returned variables are:

- client_id:

  Client identifier.

- prior_episode:

  Identifier for the earlier treatment episode.

- next_episode:

  Identifier for the subsequent treatment episode.

- prior_discharge:

  Outcome score at the final session of the earlier episode.

- next_intake:

  Outcome score at the first session of the subsequent episode.

- bad_enough_level:

  Outcome deterioration between the prior discharge and subsequent
  intake. Positive values indicate worsening.

- days_between:

  Number of days between the prior discharge and next intake.

- months_between:

  Approximate number of months between episodes, calculated as
  `days_between / 30.44`.

- loss_per_month:

  Outcome deterioration divided by the approximate number of months
  between episodes.

## Details

Sessions are first ordered by client, episode, and
session-within-episode. Each treatment episode is then reduced to its
first and final observations. Consecutive episodes are paired within
clients to create transition-level records.

When `higher_is_better = TRUE`, the bad-enough-level score is calculated
as:

\$\$ \mathrm{BEL}\_{ij} = Y\_{i,j,\mathrm{discharge}} -
Y\_{i,j+1,\mathrm{intake}} \$\$

When lower outcome scores indicate better functioning, setting
`higher_is_better = FALSE` reverses this calculation so that positive
values still represent deterioration between treatment episodes.

Clients with only one treatment episode do not contribute
transition-level observations. If no clients have multiple episodes, the
function returns an empty data frame with the expected column structure.

The `loss_per_month` variable should be interpreted cautiously. It
assumes that between-episode deterioration can be expressed as a rate
over elapsed time, even though no outcome measurements are observed
during the interval.

## See also

[`describe_episodes()`](https://frostnd.github.io/leap/reference/describe_episodes.md),
[`plot_episode_change()`](https://frostnd.github.io/leap/reference/plot_episode_change.md)

## Examples

``` r
if (FALSE) { # \dontrun{
transition_data <- episode_slopes(
  data = treatment_data,
  client = "client_id",
  episode = "episode_id",
  episode_session = "episode_session",
  date = "session_date",
  outcome = "outcome"
)

head(transition_data)

# For outcomes where lower scores indicate better functioning
transition_data <- episode_breaks(
  data = treatment_data,
  higher_is_better = FALSE
)
} # }
```

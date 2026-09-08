# Describe treatment episodes

Summarizes treatment episodes across clients using session-level
psychotherapy data. For each treatment episode number, the function
reports the number of clients contributing data, the total number of
sessions, average time between sessions, and average outcome score.

## Usage

``` r
describe_episodes(
  data,
  client = "client_id",
  episode = "episode_id",
  outcome = "outcome",
  date = "session_date"
)
```

## Arguments

- data:

  A data frame containing session-level treatment records. The data must
  contain `client_id`, `episode_id`, `session_lag`, and `outcome`.

## Value

A data frame containing one row per treatment episode number with the
following variables:

- episode_id:

  Treatment episode number.

- n_clients:

  Number of unique clients contributing observations to the episode.

- n_sessions:

  Total number of sessions observed in the episode.

- mean_session_lag:

  Mean number of days between consecutive sessions within the episode.

- mean_outcome:

  Mean outcome score across sessions within the episode.

## Details

`describe_episodes()` provides sample-level descriptive statistics for
successive treatment episodes. For example, the row corresponding to
Episode 2 summarizes all clients who contributed a second treatment
episode.

Because clients may attend different numbers of treatment episodes, the
number and composition of clients contributing observations may differ
across episode numbers. Statistics for later episodes should therefore
not be interpreted as repeated summaries of an identical client cohort.

The function assumes that session lags and treatment episode identifiers
have already been derived. These variables can be created using
[`add_session_lag()`](https://frostnd.github.io/leap/reference/add_session_lag.md)
and
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md),
or as part of the standard episode-preparation workflow using
[`add_episode_vars()`](https://frostnd.github.io/leap/reference/add_episode_vars.md).

Undefined session lags, including the first session observed for each
client, are excluded when calculating `mean_session_lag`.

## See also

[`add_episode_vars()`](https://frostnd.github.io/leap/reference/add_episode_vars.md),
[`add_session_lag()`](https://frostnd.github.io/leap/reference/add_session_lag.md),
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Prepare session-level episode data
df <- add_episode_vars(raw_data)

# Summarize successive treatment episodes
describe_episodes(df)
} # }
```

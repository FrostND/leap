# Order longitudinal session records

Orders longitudinal treatment records either chronologically by client
and session date or structurally by client, treatment episode, and
session within episode.

## Usage

``` r
order_sessions(data, by = c("date", "episode"))
```

## Arguments

- data:

  A data frame containing session-level treatment records.

- by:

  Character string specifying how records should be ordered. Must be
  either `"date"` or `"episode"`. When `by = "date"`, records are
  ordered by `client_id` and `session_date`. When `by = "episode"`,
  records are ordered by `client_id`, `episode_id`, and
  `episode_session`. Defaults to `"date"`.

## Value

A data frame containing the original observations in the requested
order. Row names are reset after sorting.

## Details

Proper ordering is important before calculating session lags,
identifying treatment episodes, or performing episode-level analyses.

When `by = "date"`, the function requires the standardized variables
`client_id` and `session_date`. This option is intended primarily for
raw data before treatment episodes have been identified.

When `by = "episode"`, the function requires `client_id`, `episode_id`,
and `episode_session`. This option is intended for data that have
already been processed using episodeR.

Missing values in any variable used for sorting result in an error
because they prevent unambiguous ordering of session records.

## See also

[`cols_standard()`](https://frostnd.github.io/leap/reference/cols_standard.md),
[`add_session_lag()`](https://frostnd.github.io/leap/reference/add_session_lag.md),
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md),
[`add_episode_session()`](https://frostnd.github.io/leap/reference/add_episode_session.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Sort raw records chronologically within clients
data <- sort_sessions(
  data = treatment_data,
  by = "date"
)

# Sort prepared data by treatment episode and session
data <- sort_sessions(
  data = treatment_data,
  by = "episode"
)

# Compatible with the native R pipe
treatment_data |>
  sort_sessions(by = "date") |>
  add_session_lag()
} # }
```

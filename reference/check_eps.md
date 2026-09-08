# Check treatment episode data

Performs a set of structural and data-quality checks on longitudinal
treatment episode data. The function summarizes sample characteristics,
evaluates missingness, verifies session ordering, and identifies
potentially problematic episode structures.

## Usage

``` r
check_eps(
  data,
  client = "client_id",
  episode = "episode_id",
  session = "episode_session",
  date = "session_date",
  outcome = "outcome"
)
```

## Arguments

- data:

  A data frame containing longitudinal treatment-session records.

- client:

  Character string specifying the client identifier column. Defaults to
  `"client_id"`.

- episode:

  Character string specifying the treatment episode identifier column.
  Defaults to `"episode_id"`.

- session:

  Character string specifying the session-within-episode column.
  Defaults to `"episode_session"`.

- date:

  Character string specifying the session date column. Defaults to
  `"session_date"`.

- outcome:

  Character string specifying the outcome variable. Defaults to
  `"outcome"`.

## Value

A one-row data frame containing diagnostic information:

- n_rows:

  Total number of session records.

- n_clients:

  Number of unique clients.

- n_episodes:

  Number of unique client-by-episode combinations.

- n_missing:

  Total number of missing values across the data frame.

- n_missing_outcome:

  Number of missing outcome observations.

- n_missing_date:

  Number of missing session dates.

- n_single_session:

  Number of treatment episodes containing only one session.

- n_short_episode:

  Number of treatment episodes containing four or fewer sessions.

- correctly_ordered:

  Logical indicating whether observations are ordered by client,
  episode, and session-within-episode.

- sequential_sessions:

  Logical indicating whether session numbering begins at 1 and proceeds
  sequentially within each episode.

- chronological_dates:

  Logical indicating whether session dates occur in chronological order
  within treatment episodes.

## Details

Required columns are first checked using
[`cols_standard()`](https://frostnd.github.io/leap/reference/cols_standard.md).
Treatment episodes are then evaluated for common structural problems
that may affect episode-level analyses.

Warnings are issued when:

- outcome observations are missing;

- session dates are missing;

- records are not correctly ordered;

- session numbering is not sequential within episodes;

- session dates are not chronological within episodes;

- one-session episodes are present; or

- episodes contain four or fewer sessions.

Episodes with four or fewer sessions are flagged because estimates of
within-episode growth may be unstable when based on relatively few
observations.

The function does not modify the supplied data.

## See also

[`describe_episodes()`](https://frostnd.github.io/leap/reference/describe_episodes.md),
[`episode_slopes()`](https://frostnd.github.io/leap/reference/episode_slopes.md)

## Examples

``` r
if (FALSE) { # \dontrun{
diagnostics <- check_episodes(
  data = treatment_data,
  client = "client_id",
  episode = "episode_id",
  session = "episode_session",
  date = "session_date",
  outcome = "outcome"
)

diagnostics
} # }
```

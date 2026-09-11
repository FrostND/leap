# Check whether raw treatment data are ready for episode preparation

Evaluates whether a raw longitudinal treatment dataset contains the
user-supplied variables required for episode construction and identifies
episode-related variables that have not yet been created.

## Usage

``` r
check_raw(
  data,
  client = "client_id",
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

- date:

  Character string specifying the session date column. Defaults to
  `"session_date"`.

- outcome:

  Character string specifying the outcome variable. Defaults to
  `"outcome"`.

## Value

A data frame describing the expected variables, whether each variable is
present, and the recommended action when it is missing.

- variable:

  Conceptual role of the variable within the episode workflow.

- column:

  Expected column name.

- type:

  Whether the variable is required from the user or derived by episodeR.

- present:

  Logical indicating whether the column is present in `data`.

- action:

  Recommended action based on the current dataset.

## Details

The function is intended as an initial diagnostic before running the
episode-preparation workflow.

The function distinguishes between two types of variables:

- **Required variables** must be supplied by the user and include a
  client identifier, session date, and outcome variable.

- **Derived variables** are created during episode preparation and
  include session lags, episode identifiers, session-within-episode
  numbers, client-episode identifiers, and episode counts.

Missing derived variables are not treated as errors. Instead, the
returned diagnostic table identifies the episodeR function that can be
used to create each variable.

Additional warnings are issued when client identifiers, session dates,
or outcome values contain missing observations. A warning is also issued
when the session date variable does not inherit from class `Date`.

The function does not modify the supplied data.

## See also

`check_eps()`,
[`add_session_lag()`](https://frostnd.github.io/leap/reference/add_session_lag.md),
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md),
[`add_episode_session()`](https://frostnd.github.io/leap/reference/add_episode_session.md),
[`add_client_episode_id()`](https://frostnd.github.io/leap/reference/add_client_episode_id.md),
[`add_episode_count()`](https://frostnd.github.io/leap/reference/add_episode_count.md)

## Examples

``` r
if (FALSE) { # \dontrun{
check_raw(
  data = treatment_data,
  client = "client_id",
  date = "session_date",
  outcome = "outcome"
)
} # }
```

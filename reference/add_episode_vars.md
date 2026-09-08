# Derive and build all treatment episode variables from raw longitudinal data.

First sorts psychotherapy session records, calculates session lags,
identifies distinct treatment episodes per client, and assigns session
numbers within episodes, tabulates total episodes for each individual.

## Usage

``` r
add_episode_vars(data, delimiter = 90)
```

## Arguments

- data:

  A data frame containing longitudinal psychotherapy records.

- client:

  Character string specifying the name of the client identifier
  variable.

- date:

  Character string specifying the name of the session date variable. The
  variable must be of class `Date`.

- threshold:

  Numeric value indicating the minimum number of days required to define
  a new treatment episode. Defaults to 90.

## Value

A data frame with the following additional variables:

- session_lag:

  Number of days since the previous session.

- episode_id:

  Treatment episode identifier.

- episode_session:

  Session number within treatment episode.

## Details

This function provides a convenient wrapper around
[`order_sessions()`](https://frostnd.github.io/leap/reference/order_sessions.md),
[`add_session_lag()`](https://frostnd.github.io/leap/reference/add_session_lag.md),
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md),
[`add_episode_session()`](https://frostnd.github.io/leap/reference/add_episode_session.md),
and
[`add_episode_count()`](https://frostnd.github.io/leap/reference/add_episode_count.md)
for users who wish to prepare episode-level data in a single step.

Treatment episodes are identified when the elapsed time between two
consecutive sessions meets or exceeds the specified threshold. By
default, a gap of 90 or more days indicates the beginning of a new
treatment episode.

# Identify unique treatment episodes

Assigns a unique episode number to each session record within a client.
A new treatment episode is identified whenever the elapsed time between
consecutive sessions exceeds a user-defined threshold. By default,
treatment episodes are separated by 90 or more days, but this default
value can be altered by the user by specifying a different value for the
threshold argument.

## Usage

``` r
add_episode_id(data, delimiter = 90)
```

## Arguments

- data:

  A longitudinal data frame

- client:

  unique client identifier

- session_lag:

  lag time between sessions

- threshold:

  elapsed time used to demarcate treatment episodes

## Value

A data frame with an additional variable, `episode_id`, indicating the
episode membership of each session.

## Details

This function assumes records are sorted chronologically within client
and that session lags have already been calculated. Users should first
apply
[`order_sessions()`](https://frostnd.github.io/leap/reference/order_sessions.md)
followed by
[`add_session_lag()`](https://frostnd.github.io/leap/reference/add_session_lag.md)
before identifying treatment episodes.

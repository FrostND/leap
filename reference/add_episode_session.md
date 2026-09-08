# Add session number within treatment episode

Creates a consecutive session number within each client and treatment
episode. The resulting variable indicates the order of each session
within its episode.

## Usage

``` r
add_episode_session(data, client, episode)
```

## Arguments

- data:

  A data frame containing session-level psychotherapy records.

- client:

  Character string specifying the name of the client identifier
  variable.

- episode:

  Character string specifying the name of the treatment episode
  identifier variable.

- ...:

  Additional arguments. Currently unused.

## Value

A data frame with an additional variable, `episode_session`, indicating
the consecutive session number within each treatment episode.

## Details

This function assumes that records are already sorted chronologically
within client and episode. Use
[`order_sessions()`](https://frostnd.github.io/leap/reference/order_sessions.md)
before identifying episodes and adding episode-specific session numbers.

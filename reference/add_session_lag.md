# Calculates the number of days between psychotherapy sessions.

Calculates the number of days elapsed between consecutive psychotherapy
sessions within each client. The first session for each client is
assigned a lag value of 0. Records should be sorted by client and
session date prior to calling this function.

## Usage

``` r
add_session_lag(data)
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

## Value

A data frame with an additional variable, `session_lag`, representing
the number of days since the previous session for each client.

## Details

Session lags are calculated separately for each client using the
difference between consecutive session dates. Incorrect results may
occur if records are not ordered chronologically within client. Use
[`order_sessions()`](https://frostnd.github.io/leap/reference/order_sessions.md)
before calculating session lags.

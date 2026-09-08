# Standardize raw data column names

Renames user-supplied variables to the standard naming convention used
throughout the leap package. Standardizing column names at the beginning
of the analysis workflow allows downstream functions to assume a
consistent data structure without requiring repeated specification of
variable names.

## Usage

``` r
cols_standard(data, client, session, outcome, date = NULL)
```

## Arguments

- data:

  A data frame containing psychotherapy session records.

- client:

  Character string specifying the client identifier column.

- session:

  Character string specifying the session identifier column.

- outcome:

  Character string specifying the outcome variable.

- date:

  Optional character string specifying the session date column. Defaults
  to `NULL`.

## Value

A data frame with standardized column names.

- client_id:

  Client identifier.

- session_id:

  Session identifier.

- outcome:

  Outcome variable.

- session_date:

  Session date, if supplied.

## Details

This function standardizes only the variables supplied by the user.
Episode- level variables such as `episode_id`, `episode_session`,
`client_episode_id`, and `n_episodes` are created later by episodeR
during episode preparation.

Standardizing variable names once at the beginning of an analysis
eliminates the need to repeatedly specify column names in downstream
functions.

The function does not modify the contents of any variables; only their
names are changed.

## See also

[`check_raw()`](https://frostnd.github.io/leap/reference/check_raw.md),
[`add_session_lag()`](https://frostnd.github.io/leap/reference/add_session_lag.md),
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data <- cols_standardize(
  data = treatment_data,
  client = "patient",
  session = "visit_number",
  outcome = "bhm_total",
  date = "visit_date"
)

names(data)
} # }
```

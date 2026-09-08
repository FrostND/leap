# Estimate episode-specific slopes and pre-post change

Estimates a linear growth rate and pre-post change score for each client
treatment episode. A separate ordinary least squares regression is
fitted within each episode to estimate change per session, while the
pre-post change score summarizes the total change between the first and
final observed sessions.

## Usage

``` r
episode_slopes(data, higher_is_better = TRUE)
```

## Arguments

- data:

  A data frame containing psychotherapy session records.

- higher_is_better:

  Logical indicating whether larger outcome values represent better
  functioning. When `TRUE` (default), change is calculated as
  `post - pre` and the estimated slope is returned unchanged. When
  `FALSE`, change is calculated as `pre - post` and the estimated slope
  is multiplied by `-1`, so that positive values consistently indicate
  improvement.

- client:

  Character string specifying the client identifier column. Defaults to
  `"client_id"`.

- episode:

  Character string specifying the treatment episode identifier column.
  Defaults to `"episode_id"`.

- episode_session:

  Character string specifying the session number within each treatment
  episode. Defaults to `"episode_session"`.

- outcome:

  Character string specifying the outcome variable. Defaults to
  `"outcome"`.

## Value

A data frame containing one row per client treatment episode with the
following variables:

- client_id:

  Client identifier.

- episode_id:

  Treatment episode identifier.

- n_sessions:

  Number of sessions observed within the episode.

- n_episodes:

  Total number of treatment episodes attended by the client.

- pre:

  Outcome score at the first observed session of the episode.

- post:

  Outcome score at the final observed session of the episode.

- change:

  Episode pre-post change score. Positive values indicate improvement.

- slope:

  Estimated linear rate of outcome change per session. Positive values
  indicate improvement.

## Details

For each client treatment episode, the function estimates the linear
model:

\$\$ Y\_{ij} = \beta\_{0j} + \beta\_{1j}(\mathrm{Session}\_{ij}) +
\varepsilon\_{ij} \$\$

where \\\beta\_{1j}\\ represents the estimated episode-specific rate of
change per session.

The episode change score is calculated from the first and final observed
sessions. When `higher_is_better = TRUE`,

\$\$ \mathrm{Change}\_j = Y\_{j,\mathrm{final}} -
Y\_{j,\mathrm{initial}} \$\$

whereas setting `higher_is_better = FALSE` reverses the subtraction so
that positive values continue to indicate clinical improvement.
Likewise, the estimated slope is multiplied by `-1` when lower outcome
values indicate better functioning.

The change score represents the total observed improvement over an
episode, whereas the slope represents the estimated rate of improvement
per session. These quantities may differ substantially when episode
lengths vary.

Episodes containing fewer than two sessions cannot support estimation of
a linear growth rate and trigger a warning. Episodes containing four or
fewer sessions are also flagged because their estimated slopes may be
unstable.

This function assumes that treatment episodes have already been
identified using
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md)
and that session numbers within episodes have been assigned using
[`add_episode_session()`](https://frostnd.github.io/leap/reference/add_episode_session.md).

## See also

[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md),
[`add_episode_session()`](https://frostnd.github.io/leap/reference/add_episode_session.md),
[`describe_episodes()`](https://frostnd.github.io/leap/reference/describe_episodes.md),
[`fit_sao()`](https://frostnd.github.io/leap/reference/fit_sao.md)

## Examples

``` r
if (FALSE) { # \dontrun{
episode_estimates <- episode_slopes(
  data = treatment_data,
  client = "client_id",
  episode = "episode_id",
  episode_session = "episode_session",
  outcome = "outcome"
)

head(episode_estimates)

# Outcome where lower scores indicate improvement
episode_estimates <- episode_slopes(
  data = treatment_data,
  outcome = "symptom_score",
  higher_is_better = FALSE
)
} # }
```

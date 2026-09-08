# Add a unique client-episode identifier

Creates a character identifier for each unique client-episode
combination by concatenating the client and episode identifiers. This
variable is useful for indexing episode-level random effects, subsetting
treatment episodes, and uniquely identifying observations belonging to
the same episode.

## Usage

``` r
add_client_episode_id(data)
```

## Arguments

- data:

  A data frame containing client and episode identifiers.

- client:

  Unquoted column name identifying clients.

- episode:

  Unquoted column name identifying treatment episodes.

- name:

  Name of the new identifier column. Defaults to `"client_episode_id"`.

## Value

The input data frame with an additional character variable containing a
unique identifier for each client-episode combination.

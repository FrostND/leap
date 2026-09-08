# Classify clients by treatment attendance

Creates client-level attendance variables based on the number of
treatment episodes attended.This variable can easily be used to subset
clients based based on the total number of episodes they attended.

## Usage

``` r
add_episode_count(data)
```

## Arguments

- data:

  A data frame containing psychotherapy session records.

- client:

  Character string specifying the name of the client identifier
  variable.

- episode:

  Character string specifying the name of the treatment episode
  identifier variable.

## Value

A data frame with two additional variables:

- `n_episodes`

## Details

One variable is added to the data:

- n_episodes:

  Total number of treatment episodes attended by the client.

This function assumes that treatment episodes have already been
identified using
[`add_episode_id()`](https://frostnd.github.io/leap/reference/add_episode_id.md)

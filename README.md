
<!-- README.md is generated from README.Rmd. Please edit that file -->

# leap <img src="inst/figures/leap_hex.png" align="right" height="128"/>

The longitudinal episode analysis and procedures (`leap`) package
provides tools for identifying, describing, visualizing, and analyzing
repeated treatment episodes in longitudinal psychotherapy and behavioral
health data. `leap` supports workflows for defining treatment episodes,
characterizing within- and between-episode patterns, and modeling change
across successive episodes.

<!-- badges: start -->

<!-- badges: end -->

## Installation

You can install the development version of leap from GitHub.

``` r
# install.packages("pak")
# pak::pak("leap") 
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
## add episode variables from raw longitudinal data
# episode_df <- add_episode_vars(data)
```

## Motivation

The `leap()` package was developed to serve two main aims. The first is
to provide researchers with a set of pre-made R tools to analyze
psychotherapy treatment episodes. Therefore, this package contains a
suite of useful R functions to wrangle, summarize, and explore
psychotherapy data that contains multiple episodes of care.

The second aim of the leap() package is to test various statistical
approaches to modeling therapeutic outcomes with multi-episode data - an
issue that has received less attention in either the psychotherapy or
methodology research literature. Using three alternative approaches,
including longitudinal growth modeling, slopes as outcomes, and Bayesian
modeling, investigators can use leap to analyze multiepisode data.

The leap package includes psychotherapy outcome data sets, etc…

# Package index

#### Pre-Processing

`check_raw()`, `cols_standard()`, `cols_validate()`, `order_sessions()`,

#### Add Episode Variables

`add_session_lag()`, `add_episode_id()`, `add_episode_session()`,
`add_client_episode_id()`, `add_episode_count()`, `add_episode_vars()`,
`lag_delimiter()`

#### Checking and Filtering

`check_eps()`, `filter_episodes()`, `filter_cohort()`

#### Episode Summaries

`describe_episodes()`, `episode_slopes()`, `episode_breaks()`

#### Statistical Modeling

`fit_lme()`, `fit_sao()`, `fit_bel()`, `fit_brms()`

#### Model Diagnostics

`compare_lme_fit()`, `episode_icc()`, `episode_pwr()`

#### Visualization

`plot_episode_curves()`, `plot_episode_change()`, `plot_episode_loss()`,
`plot_lag_density()`, `plot_cohort_curves()`, `plot_cohort_change()`

#### Internal Helpers

`cols_validate()`, `pivot_clients_wide()`, `pivot_episodes_wide()`,
`map_models()`

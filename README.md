
<!-- README.md is generated from README.Rmd. Please edit that file -->

# leap <img src="inst/figures/leap_hex_test.png" align="right" height="138"/>

<!-- badges: start -->

<!-- badges: end -->

Provides tools for identifying, describing and analyzing repeated
treatment episodes in longitudinal psychotherapy and behavioral health
research.

## Installation

To get a bug fix or to use a feature from the development version, you
can install the development version of leap from GitHub.

``` r
# install.packages("pak")
# pak::pak("leap") 
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.

## Motivation

The leap() package was developed to serve two main aims. The first is to
provide researchers with a set of pre-made R tools to analyze
psychotherapy treatment episodes. Therefore, this package contains a
suite of useful R functions to wrangle, summarize, and explore
psychotherapy data that contains multiple episodes of care.

The second aim of the leap() package is to test various statistical
approaches to modeling therapeutic outcomes with multi-episode data - an
issue that has received less attention in either the psychotherapy or
methodology research literature. Using three alternative approaches,
including longitudinal growth modeling, slopes as outcomes, and Bayesian
modeling, investigators can use leap to analyze multiepisode data.

The episode R package includes psychotherapy outcome data sets, etc…

# Function Organization

### Data Preparation

`cols_standardize()`, `check_raw_data()`, `sort_sessions()`,
`add_session_lag()`, `add_episode_id()`, `add_episode_session()`,
`add_client_episode_id()`, `add_episode_count()`

### Data Checking and Filtering

`check_episode_data()`, `check_episode_gaps()`, `filter_episodes()`,
`filter_cohort()`, `filter_responder()`, `sample_episode()`

### Episode Summaries

`describe_episodes()`, `estimate_episode_slopes()`,
`build_transition_data()`

### Statistical Modeling

`fit_lme()`, `fit_lme_selection()`, `fit_sao()`, `fit_bel()`,
`fit_brms()`

### Model Diagnostics

`compare_episode_models()`, `episode_icc()`, `episode_pwr()`

### Visualization

`plot_episode_curves()`, `plot_cohort_curves()`,
`plot_episode_change()`, `plot_cohort_change()`,
`plot_sampled_episode()`, `plot_episode_distributions()`

### Data Restructuring

### Internal Helpers

`cols_validate()`, `pivot_clients_wide()`, `pivot_episodes_wide()`,
`map_models()`

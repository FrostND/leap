
<!-- README.md is generated from README.Rmd. Please edit that file -->

# leap <img src="inst/figures/logo.png" align="right" height="118"/>

The **L**ongitudinal **E**pisode **A**nalysis and **P**rocedures
(`leap`) package provides tools for identifying, describing,
visualizing, and analyzing repeated treatment episodes in longitudinal
behavioral health data, with particular applications to psychotherapy
research.

`leap` supports the treatment episode workflow from episode
identification through statistical analysis, including tools for
defining episodes, characterizing within- and between-episode patterns,
and modeling change across successive episodes.

<!-- badges: start -->

<!-- badges: end -->

## Installation

You can install the development version of `leap` from GitHub.

``` r
# install devtools 
install.packages("devtools")

# download developement version 
install_github("FrostND/leap")
```

## Motivation

Psychotherapy is often represented as a single, continuous course of
treatment. In real world contexts, however, individuals may disengage
from care and subsequently return for additional treatment, producing
multiple distinct episodes of care. Analyzing these complex longitudinal
data requires decisions about how episodes of care are defined,
represented, and incorporated into statistical modeling and data
analysis.

The `leap` package was developed with two primary aims:

First, the package provides a set of tools for preparing and exploring
multi-episode psychotherapy data. These functions support common tasks
such as identifying temporal breaks in treatment, constructing
episode-level variables, describing patterns of service utilization, and
visualizing change within and between unique treatment episodes.

Second, `leap` provides tools for investigating alternative approaches
to modeling therapeutic change across repeated episodes of care. These
include longitudinal mixed-effects models, slopes-as-outcomes models,
and Bayesian multilevel models. Together, these approaches allow
researchers to examine both change occurring within treatment episodes
and patterns of change across different episodes.

## Basic workflow

A typical `leap` workflow consists of identifying unique treatment
episodes in longitudinal health records data, describing the resulting
episode structure, and then visualizing or modeling change across
episodes.

### Identify treatment episodes

``` r
# Data check 
check_raw(data)

# Derive episodes from raw 
episode_data <- add_episode_vars(data)

# Check the episode structure 
check_eps(episode_data)
```

### Describe treatment episodes

``` r
describe_episodes(episode_data)
```

### Model change across episodes

``` r
# mixed-effects growth model 
fit_lme(episode_data, cohort = "all", model = "episode")
```

### Visualize treatment trajectories

``` r
# plot growth rates by episode 
plot_episode_curves(episode_data)
```

## Episode identification

Treatment episodes are commonly defined using a predetermined period of
inactivity, such as 90 days without treatment. `leap` supports this
approach while also providing tools for examining the empirical
distribution of time between sessions.

Session lags can be calculated and inspected directly:

``` r
episode_data <- data |>
  add_session_lag() |>
  add_episode_id(delimiter = 90)
```

Candidate episode delimiters can also be estimated from the observed
distribution of session lags:

``` r
lag_delimiter(data, method = "iqr")
lag_delimiter(data, method = "quantile")
lag_delimiter(data, method = "mixture")
```

The mixture-modeling approach, implemented using the `mclust` package
(Scrucca et al. 2016), treats episode identification as an empirical
classification problem by identifying relatively short- and long-gap
components in the observed distribution of session lags. Estimated
delimiters should be interpreted as data-informed candidate thresholds
rather than definitive clinical boundaries between treatment episodes.

## Modeling treatment episodes

`leap` currently supports several complementary approaches to analyzing
change across repeated treatment episodes:

- `fit_lme()` fits longitudinal mixed-effects models directly to
  session-level observations.
- `fit_sao()` uses episode-specific rates of change as outcomes in a
  slopes-as-outcomes framework.
- `fit_brms()` fits Bayesian multilevel models of session-level
  treatment trajectories.

Frequentist mixed-effects models are estimated using `lme4` (Bates et
al. 2015) whereas Bayesian multilevel models are estimated using `brms`
(Bürkner 2017). These approaches address related but distinct questions
about therapeutic change and the structure of repeated episodes of care.

`leap` includes simulated psychotherapy data for demonstrating episode
identification, visualization, and statistical modeling. The simulated
data illustrate common features of longitudinal treatment records,
including unequal numbers of sessions, repeated episodes of care, and
variation in within- and between-episode change.

## Development

`leap` is under active development. Function names, arguments, and model
specifications may change in future releases.

# Package index

### Pre-Processing

`check_raw()`, `cols_standard()`, `order_sessions()`

### Add Episode Variables

`add_session_lag()`, `add_episode_id()`, `add_episode_session()`,
`add_client_episode_id()`, `add_episode_count()`, `add_episode_vars()`,
`lag_delimiter()`

### Checking and Filtering

`check_eps()`, `filter_episodes()`

### Episode Summaries

`describe_episodes()`, `episode_slopes()`, `episode_breaks()`

### Statistical Modeling

`fit_lme()`, `fit_sao()`, `fit_bel()`, `fit_brms()`

### Model Diagnostics

`compare_lme_fit()`, `episode_icc()`, `episode_pwr()`

### Visualization

`plot_episode_curves()`, `plot_episode_change()`, `plot_episode_loss()`,
`plot_lag_density()`, `plot_cohort_curves()`, `plot_cohort_change()`

### Internal Helpers

`cols_validate()`, `filter_cohort()`

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-bates2015" class="csl-entry">

Bates, Douglas, Martin Mächler, Ben Bolker, and Steve Walker. 2015.
“Fitting Linear Mixed-Effects Models Using Lme4.” *Journal of
Statistical Software* 67 (1): 1–48.

</div>

<div id="ref-burkner2017" class="csl-entry">

Bürkner, Paul-Christian. 2017. “Brms: An r Package for Bayesian
Multilevel Models Using Stan.” *Journal of Statistical Software* 80 (1):
1–28.

</div>

<div id="ref-scrucca2016" class="csl-entry">

Scrucca, Luca, Michael Fop, T. Brendan Murphy, and Adrian E. Raftery.
2016. “Mclust 5: Clustering, Classification and Density Estimation Using
Gaussian Finite Mixture Models.” *The R Journal* 8 (1): 289–317.

</div>

</div>

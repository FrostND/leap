
<!-- README.md is generated from README.Rmd. Please edit that file -->

# leap <img src="inst/figures/logo.png" align="right" height="138"/>

The **L**ongitudinal **E**pisode **A**nalysis and **P**rocedures
(`leap`) package provides tools for identifying, visualizing, and
statistically modeling repeated treatment episodes in longitudinal data,
with particular emphasis on psychotherapy and behavioral health records.

<!-- badges: start -->

[![R-CMD-check](https://github.com/FrostND/leap/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/FrostND/leap/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

## Why leap?

Behavioral health interventions, including psychotherapy, are often
represented as a single, continuous course of treatment. In naturalistic
settings, however, individuals may disengage from an intervention and
subsequently reengage, resulting in multiple distinct periods of
treatment exposure over time. When records accumulate across months or
years, these patterns can produce complex longitudinal data structures
that require decisions about how episodes of treatment are defined,
represented, and statistically incorporated in intervention research.

`leap` was developed to support two related components of this analytic
workflow. First, it provides easy-to-use tools for preparing and
exploring multi-episode data, including identifying breaks in treatment,
constructing episode-level variables, describing patterns of service
utilization.

Second, `leap` provides flexible tools for modeling change across
repeated episodes of care. Supported approaches include longitudinal
mixed-effects models, slopes-as-outcomes models, and Bayesian multilevel
models, allowing researchers to examine change within individual
episodes as well as patterns of change across episodes.

## What can leap do?

- Identify treatment episodes from longitudinal session data
- Construct and summarize episode-level variables
- Describe patterns of treatment utilization across episodes
- Visualize change within and across treatment episodes
- Model repeated treatment trajectories using Frequentist and Bayesian
  approaches

## Installation

You can install the development version of `leap` from GitHub.

``` r
# install devtools 
install.packages("devtools")

# download development version 
install_github("FrostND/leap")
```

## Get Started

For a complete introduction to the `leap` workflow, see [Get Started
with leap](articles/leap.html)

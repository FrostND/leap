
<!-- README.md is generated from README.Rmd. Please edit that file -->

# leap <img src="inst/figures/logo.png" align="right" height="128"/>

The **L**ongitudinal **E**pisode **A**nalysis and **P**rocedures
(`leap`) package provides R tools for identifying, visualizing, and
modeling repeated treatment episodes in longitudinal behavioral health
data, with particular applications to psychotherapy data.

<!-- badges: start -->

[![R-CMD-check](https://github.com/FrostND/leap/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/FrostND/leap/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

## Why leap?

Psychotherapy is often represented as a single, continuous course of
treatment. In real world contexts, however, individuals may disengage
from care and subsequently return for additional treatment, producing
multiple distinct episodes of care. Analyzing these complex longitudinal
data requires decisions about how episodes of care are defined,
represented, and incorporated into statistical modeling and data
analysis.

`leap` was developed to support two related aspects of this process.
First, it provides tools for preparing and exploring multi-episode data,
including identifying breaks in treatment, constructing episode-level
variables, describing patterns of service utilization.

Second, leap provides flexible tools for modeling therapeutic change
across repeated episodes of care. Supported approaches include
longitudinal mixed-effects models, slopes-as-outcomes models, and
Bayesian multilevel models, allowing researchers to examine both change
within individual treatment episodes and patterns of change across
episodes.

## What can leap do?

- Identify treatment episodes from longitudinal session data
- Construct and summarize episode-level variables
- Describe patterns of treatment utilization across episodes
- Visualize change within and across treatment episodes
- Model repeated treatment trajectories using frequentist and Bayesian
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

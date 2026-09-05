
<!-- README.md is generated from README.Rmd. Please edit that file -->

# leap <img src="inst/figures/logo.png" align="right" height="128"/>

The **L**ongitudinal **E**pisode **A**nalysis and **P**rocedures
(`leap`) package provides tools for identifying, describing,
visualizing, and analyzing repeated treatment episodes in longitudinal
behavioral health data, with particular applications to psychotherapy
research.

<!-- badges: start -->

[![R-CMD-check](https://github.com/FrostND/leap/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/FrostND/leap/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Why leap?

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

## What can leap do?

- Identify treatment episodes from longitudinal session data
- Describe within- and between-episode patterns
- Visualize repeated treatment trajectories
- Model change within and across episodes
- Fit frequentist and Bayesian multilevel models

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

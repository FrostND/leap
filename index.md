# leap

The **L**ongitudinal **E**pisode **A**nalysis and **P**rocedures
(`leap`) package provides tools to identify, visualize, and
statistically model repeated treatment episodes in longitudinal health
records.

## Why leap?

Behavioral health interventions, including psychotherapy, are often
represented as a single, discrete period of treatment. In real-world
settings, however, individuals may disengage and subsequently reengage
in treatment over time, resulting in multiple distinct periods
(i.e. episodes) of treatment exposure. These patterns can produce
complex longitudinal data that require decisions about how episodes of
treatment are defined, represented, and incorporated into statistical
analyses.

`leap` was developed to address these challenges in two complementary
ways. First, it provides easy-to-use tools for preparing and exploring
health records that contain multiple episodes of treatment, including
identifying breaks in care, constructing episode-level variables, and
visualizing patterns within and across episodes.

Second, `leap` supports several approaches for modeling change across
repeated episodes of treatment, including longitudinal mixed-effects
models, slopes-as-outcomes models, and Bayesian multilevel models.
Together, these capabilities allow researchers to examine change within
individual episodes as well as patterns of change across episodes over
time.

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

install.packages("remotes")
remotes::install_github("FrostND/leap")
```

## Get Started

For a complete introduction to the `leap` workflow, see [Get Started
with leap](https://frostnd.github.io/leap/articles/leap.md)

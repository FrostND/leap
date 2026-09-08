# leap

The **L**ongitudinal **E**pisode **A**nalysis and **P**rocedures
(`leap`) package provides tools to identify, visualize, and
statistically model repeated treatment episodes in longitudinal health
records data.

## Why leap?

Behavioral health interventions, including psychotherapy, are often
represented as a single, continuous course of treatment. In real-world
settings, however, individuals often disengage and subsequently reengage
in treatment over time, resulting in multiple distinct periods
(i.e. episodes) of intervention exposure. These patterns can produce
complex longitudinal data that require decisions about how episodes of
treatment are defined, represented, and incorporated into statistical
analyses.

Despite the occurrence of repeated treatment episodes, longitudinal
intervention studies often restrict analyses to a single episode of
care, such as an individual’s first or most recent episode. Although
this approach simplifies the analysis, it excludes information about
subsequent treatment exposure and limits the ability to examine how
patterns of change may differ across repeated episodes.

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

# install devtools 
install.packages("devtools")

# download development version 
install_github("FrostND/leap")
```

## Get Started

For a complete introduction to the `leap` workflow, see [Get Started
with leap](https://frostnd.github.io/leap/articles/leap.md)

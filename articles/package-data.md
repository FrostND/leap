# Package Data

## Overview

`leap` is designed for longitudinal treatment data in which individuals
contribute repeated observations over time. In psychotherapy and other
behavioral health interventions, these observations typically correspond
to treatment sessions. This article describes the hierarchical structure
of longitudinal psychotherapy data and introduces the example datasets
included with the `leap` package.

## Longitudinal data

Longitudinal psychotherapy data are inherently hierarchical, or
*nested*, because individuals contribute multiple observations over
time. This structure has important statistical implications:
observations from the same individual are likely to be correlated,
violating the independence assumption of many classical statistical
models. Appropriate analytic methods must therefore account for
variability both within and between individuals.

A central premise of `leap` and the episode-oriented workflow is that
longitudinal data may contain an additional level of nesting when
individuals participate in multiple episodes of treatment. This
structure is particularly likely in large-scale health outcome datasets,
including electronic health records and other archival data sources. In
these data, sessions are nested within treatment episodes, which are
themselves nested within clients.

The resulting data can therefore be understood as having three levels:

- **Session**: An individual treatment visit or observation.
- **Episode**: A distinct period of treatment comprising one or more
  sessions.
- **Client**: An individual who may contribute one or more treatment
  episodes.

![Figure 1. Hierarchical structure of sessions, treatment episodes, and
clients.](images/eps_nesting.png)

Figure 1. Hierarchical structure of sessions, treatment episodes, and
clients.

This structure is especially important when fitting statistical models
because sessions from the same episode—and episodes from the same
client—are related rather than independent. Multilevel modeling methods
can represent these dependencies and partition variability across the
session, episode, and client levels.

## Package data

`leap` includes simulated longitudinal psychotherapy data that exhibit
common features of real-world treatment records. The simulated data vary
along two dimensions: **design** and **scenario type**.

### Design: balanced and unbalanced

The simulated data include both balanced and unbalanced longitudinal
designs.

In the **balanced design**, clients contribute the same number of
treatment episodes and the same number of sessions within each episode.
This provides a simplified data structure that is useful for comparing
and evaluating the performance of different statistical modeling
approaches.

In the **unbalanced design**, clients may contribute different numbers
of sessions and episodes of care. This structure more closely resembles
naturalistic treatment records, where treatment duration and patterns of
reengagement vary across clients.

### Scenario type: stochastic and clinical

Within each design, `leap` provides simulations representing different
sources and patterns of variation.

**Stochastic scenarios** vary the amount of between-client and
between-episode variability in treatment trajectories. These scenarios
are useful for examining how different variance structures affect
episode-based analyses.

**Clinical scenarios** represent systematic patterns of treatment and
reengagement across episodes, such as recurrence, efficient return to
treatment, persistent difficulty, and diminishing response.

Together, these simulated data provide controlled examples for
demonstrating how `leap` functions behave across different longitudinal
data structures and patterns of change.

## Summary

Readers interested in learning more about longitudinal data analysis of
psychotherapy can find guides in the [Research
Foundations](https://frostnd.github.io/leap/articles/articles/rx-foundations.md)
article.

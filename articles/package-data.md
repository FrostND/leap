# Package Data

## Overview

This article explains how multi-episode psychotherapy data are
structured and introduces the datasets included in `leap`.

## Data structure

Longitudinal psychotherapy data contain repeated session-level
observations nested within clients. A basic premise of `leap` is that
clients may participate in multiple treatment episodes, introducing an
additional level of nesting: **sessions within episodes, and episodes
within clients**. This structure is especially relevant in electronic
health records and other archival datasets that track treatment over
extended periods.

The three levels are:

- **Session**: An individual treatment visit at which an outcome may be
  measured.
- **Episode**: A distinct period of treatment containing one or more
  sessions.
- **Client**: An individual who participates in one or more treatment
  episodes.

Figure 1 illustrates this three-level structure.

![Figure 1. Hierarchical structure of sessions, treatment episodes, and
clients.](images/eps_nesting.png)

Figure 1. Hierarchical structure of sessions, treatment episodes, and
clients.

## Data sets

`leap` includes simulated longitudinal psychotherapy datasets that
reflect common features of real-world treatment records and the
hierarchical structure illustrated in Figure 1. These datasets vary
along two key dimensions: *design* and *scenario type*.

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

### Clinical scenarios

##### Clinical scenario: diminishing therapeutic response

##### Clinical scenario: deteriorating therapeutic response

##### Clinical scenario: relapse and response

##### Clinical scenario: efficient return and response

## Summary

Readers interested in learning more about longitudinal data analysis of
psychotherapy can find guides in the [Research
Foundations](https://frostnd.github.io/leap/articles/articles/rx-foundations.md)
article.

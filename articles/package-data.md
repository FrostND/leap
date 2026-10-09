# Package Data

## Overview

This article explains how multi-episode psychotherapy data are
structured and introduces the datasets included in `leap`.

## Structure

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

## Datasets

`leap` includes simulated longitudinal psychotherapy datasets with
sessions nested within treatment episodes and episodes nested within
clients, as illustrated in Figure 1. The datasets vary by
*design*—balanced or unbalanced—and *scenario type*.

In a **balanced design**, all clients contribute the same number of
episodes, and all episodes contain the same number of sessions. This
simplified structure is useful for comparing statistical models and
evaluating their performance.

In an **unbalanced design**, the number of episodes and sessions varies
across clients. This structure more closely resembles routine treatment
records, where clients differ in how long they attend treatment and how
often they return for additional care.

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

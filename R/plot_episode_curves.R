#' Plot treatment episode trajectories
#'
#' Visualizes session-level outcome trajectories across successive treatment
#' episodes. Individual client-episode trajectories are shown in the
#' background, with a pooled linear trend superimposed within each treatment
#' episode number.
#'
#' @param data A data frame containing session-level treatment records. The
#'   data must contain `client_id`, `episode_id`, `episode_session`, and
#'   `outcome`.
#' @param outcome_limits Numeric vector of length two specifying the displayed
#'   y-axis limits. Defaults to `c(0, 25)`.
#' @param clinical_cutoff Optional numeric value specifying a clinical
#'   reference threshold to display as a horizontal dashed line. Defaults to
#'   `10`. Set to `NULL` to omit the reference line.
#'
#' @return
#' A `ggplot` object displaying individual client-episode trajectories and
#' pooled linear trends across treatment episodes.
#'
#' @details
#' `plot_episode_curves()` operates on session-level data in which treatment
#' episodes have already been identified. Each panel represents a treatment
#' episode number, such that the Episode 2 panel contains observations from
#' clients who contributed a second treatment episode.
#'
#' Individual lines connect observations within each client-specific treatment
#' episode. The superimposed solid line is estimated using a simple linear
#' regression of `outcome` on `episode_session` across all observations
#' contributing to that episode number. It therefore represents a pooled
#' descriptive trajectory rather than a multilevel model estimate.
#'
#' Because clients may attend different numbers of treatment episodes, the
#' composition of the sample may differ across panels. Apparent differences
#' between episode-specific trends should therefore be interpreted
#' descriptively and not as adjusted within-client effects.
#'
#' The plot is intended primarily for exploratory data analysis and visual
#' assessment of within-episode change prior to fitting formal longitudinal
#' models such as [fit_lme()] or [fit_brms()].
#'
#' @examples
#' \dontrun{
#' # Prepare treatment episode variables
#' df <- add_episode_vars(raw_data)
#'
#' # Plot session-level trajectories across treatment episodes
#' plot_episode_curves(df)
#'
#' # Change the displayed outcome range
#' plot_episode_curves(df, outcome_limits = c(0, 20))
#'
#' # Add a different clinical reference threshold
#' plot_episode_curves(df, clinical_cutoff = 8)
#'
#' # Omit the clinical reference line
#' plot_episode_curves(df, clinical_cutoff = NULL)
#' }
#'
#' @seealso
#' [add_episode_vars()],
#' [plot_episode_change()],
#' [fit_lme()],
#' [fit_brms()]
#'
#' @export
plot_episode_curves <- function(
  data,
  outcome_limits = c(0, 25),
  clinical_cutoff = 10
) {

  cols_validate(data, required = c("client_id", "episode_session", "episode_id", "outcome"))

  ggplot(data, aes(x = episode_session, y = outcome, group = interaction(client_id, episode_id))) +
    # Individual client-episode trajectories
    geom_line(
      color = "grey65",
      linewidth = 0.30,
      alpha = 0.08,
      lineend = "round"
    ) +
    # Clinical reference threshold
    geom_hline(
      yintercept = clinical_cutoff,
      color = "grey40",
      linetype = "dashed",
      linewidth = 0.45
    )  +
    # Average trajectory within each episode
    geom_smooth(
      aes(group = 1),
      method = "lm",
      formula = y ~ x,
      se = FALSE,
      color = "#2C3E50",
      linewidth = 1.15,
      lineend = "round"
    )+
    facet_wrap(vars(episode_id), labeller = labeller(.default = function(x) paste("Episode", x))) +
    coord_cartesian(ylim = outcome_limits, expand = TRUE) +
    scale_x_continuous(
      limits = c(1, NA),
      breaks = scales::breaks_pretty(n = 7),
      expand = expansion(mult = c(0.02, 0.02))
    ) +
    scale_y_continuous(
      breaks = scales::breaks_pretty(n = 6),
      expand = expansion(add = 1)
    ) +
    labs(
      x = "Session within episode",
      y = "Mental Health Score",
      title = "Clinical growth trajectories in each treatment episode",
      subtitle = paste(
        "Individual client-episode trajectories are shown in the background;",
        "solid lines show average linear change"
      ),
      caption = paste0(
        "Dashed line indicates the clinical reference value of ",
        clinical_cutoff,
        "."
      )
    ) +
    theme_bw(
      base_size = 11,
      base_family = "serif"
    ) +
    theme(
      # Panel
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(
        color = "grey88",
        linewidth = 0.20
        ),
      panel.border = element_rect(
        color = "black",
        fill = NA,
        linewidth = 0.45
      ),
      # Facets
      panel.spacing = unit(0.8, "lines"),
      strip.background = element_blank(),
      strip.text = element_text(
        face = "plain",
        size = 10,
        color = "black",
        margin = margin(b = 5)
      ),
      # Axes
      axis.title = element_text(
        face = "plain",
        size = 11,
        color = "black"
      ),
      axis.title.x = element_text(
        margin = margin(t = 8)
      ),
      axis.title.y = element_text(
        margin = margin(r = 8)
      ),
      axis.text = element_text(
        size = 9.5,
        color = "black"
      ),
      axis.ticks = element_line(
        color = "black",
        linewidth = 0.35
      ),
      axis.ticks.length = unit(0.12, "cm"),
      # Titles
      plot.title = element_text(
        face = "bold",
        size = 13,
        color = "black",
        hjust = 0,
        margin = margin(b = 4)
      ),
      plot.subtitle = element_text(
        face = "plain",
        size = 10.5,
        color = "grey20",
        hjust = 0,
        lineheight = 1.1,
        margin = margin(b = 10)
      ),
      # Caption
      plot.caption = element_text(
        face = "plain",
        size = 9,
        color = "grey25",
        hjust = 0,
        lineheight = 1.05,
        margin = margin(t = 8)
      ),
      # Overall spacing
      plot.margin = margin(
        t = 10,
        r = 12,
        b = 10,
        l = 10
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot"
    )
}

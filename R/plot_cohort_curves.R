#' Plot growth curves by treatment-episode cohort
#'
#' Creates a multi-panel figure showing average linear outcome trajectories
#' for clients grouped according to the total number of treatment episodes
#' attended. Separate plots are produced for one-, two-, and three-episode
#' cohorts, and treatment episodes are displayed as facets within each cohort.
#'
#' The resulting cohort plots are arranged in a staggered grid using
#' \pkg{patchwork}. An optional horizontal reference line may be added to
#' indicate a clinically meaningful outcome cutoff.
#'
#' @param df A data frame containing longitudinal treatment-session records.
#' @param episode_count Character string specifying the column containing the
#'   total number of episodes attended by each client. Defaults to
#'   `"n_episodes"`.
#' @param outcome Character string specifying the outcome variable. Defaults to
#'   `"outcome"`.
#' @param episode_id Character string specifying the treatment-episode
#'   identifier. Defaults to `"episode_id"`.
#' @param episode_session Character string specifying session number within
#'   treatment episode. Defaults to `"episode_session"`.
#' @param x_lims Optional numeric vector of length two defining the displayed
#'   x-axis limits.
#' @param y_lims Optional numeric vector of length two defining the displayed
#'   y-axis limits.
#' @param clinical_cutoff Optional numeric value indicating a clinically
#'   meaningful outcome threshold. When supplied, a dashed horizontal line is
#'   added to each panel.
#'
#' @return A \code{patchwork} object containing cohort-specific episode growth
#'   curves.
#'
#' @details
#' Clients with more than three treatment episodes are excluded. Within each
#' cohort, separate linear trajectories are estimated for each episode using
#' \code{ggplot2::geom_smooth(method = "lm")}.
#'
#' The fitted lines are extended across the displayed x-axis range using
#' \code{fullrange = TRUE}. The figure uses a common y-axis and a staggered
#' layout in which cohorts with more episodes occupy more horizontal space.
#'
#' @examples
#' \dontrun{
#' plot_cohort_curves(
#'   df = treatment_data,
#'   episode_count = "n_episodes",
#'   outcome = "outcome",
#'   episode_id = "episode_id",
#'   episode_session = "episode_session",
#'   x_range = c(1, 30),
#'   y_range = c(0, 25),
#'   clinical_cutoff = 12
#' )
#' }
#'
#' @seealso [ggplot2::geom_smooth()], [patchwork::wrap_plots()]
#'
#' @export
plot_cohort_curves <- function(
  df,
  episode_count = "n_episodes",
  outcome = "outcome",
  episode_id = "episode_id",
  episode_session = "episode_session",
  x_range = NULL,
  y_range = NULL,
  clinical_cutoff = NULL
  ) {

  # 1.Three episodes maximum
  df <- subset(df, df[[episode_count]] <= 3)

  # 2.Cohort sub-lists
  cohort_dfs <- split(df, df[[episode_count]])
  cohort_n <- length(cohort_dfs)

  # 3.Reference lm
  ref_single <- lm(outcome ~ session_id, data = cohort_dfs[[1]])

  # 4.Define plot parameters
  gg_fun <- function(df, ...) {
  ggplot(df, aes(x = session_id, y = outcome, group = episode_id)) +
    geom_smooth(
      method = "lm",
      se = FALSE,
      fullrange = TRUE,
      ...) +
    facet_wrap(
      vars(episode_id),
      nrow = 1,
      strip.position = "top",
      labeller = labeller(episode_id = function(x) paste("Episode", x))
    ) +
    labs(x = "Session", y = "Mental Health Outcome Score") +
    scale_x_continuous(limits = x_range, breaks = c(5, 10, 15, 20, 25, 30)) +
    ylim(y_range) +
    theme(
      plot.title = element_text(
        family = "Times",
        size = 10,
        hjust = 0,
        margin = margin(b = 6)
        ),
      text = element_text(family = "Times"),
      axis.title = element_text(size = 10, face = "plain"),
      axis.text = element_text(size = 9),
      strip.background = element_blank(),
      strip.text = element_text(face = "plain", size = 9, margin = margin(b = 5)),
      panel.grid.major.y = element_line(colour = "grey90", linewidth = 0.25),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      panel.spacing = unit(0.8, "lines"),
      panel.border = element_rect(fill = NA, linewidth = 0.4)
    ) +
    geom_hline(
      yintercept = clinical_cutoff,
      colour = "grey55",
      linewidth = 0.4,
      linetype = "dashed"
      )

}
# 5.Define color options
colors <- c("black", "#3B6EA8", "#B84A3A")

# 6.Run plotting function on subsets
p1 <- gg_fun(df = cohort_dfs[[1]], colour = colors[1], size = .9) +
    labs(title = "Cohort: One Treatment Episode")
p2 <- gg_fun(df = cohort_dfs[[2]], colour = colors[2], size = .9) +
  labs(title = "Cohort: Two Treatment Episodes")
p3 <- gg_fun(df = cohort_dfs[[3]], colour = colors[3], size = .9) +
  labs(title = "Cohort: Three Treatment Episodes")

# step 6: Plot grid layout
grid_layout <- "A##
                BB#
                CCC"

# step 7: Assemble plots
curves <- wrap_plots(
  A = p1,
  B = p2,
  C = p3,
  design = grid_layout,
  axes = "collect"
  ) +
  plot_annotation(
    theme = theme(
      plot.subtitle = element_text(
        family = "Times",
        size = 11,
        margin = margin(b = 8)
      ),
      plot.caption = element_text(
        family = "Times",
        size = 10,
        color = "black"
      )
    )
  )

curves

}





#' Plot outcome change across treatment episode cohorts
#'
#' @description
#' Plots intake-to-discharge outcome change for clients grouped by their total
#' number of treatment episodes. Within each cohort, the plot shows mean change
#' for each episode and, optionally, individual client trajectories.
#'
#' @param data A session-level data frame containing `client_id`, `episode_id`,
#'   `episode_session`, `outcome`, and `n_episodes`.
#' @param max_episodes Maximum number of episodes in a cohort to display.
#'   Defaults to 3.
#' @param higher_is_better If `TRUE`, change is discharge minus intake.
#'   If `FALSE`, change is intake minus discharge. Positive values therefore
#'   indicate improvement in either case.
#' @param show_individuals If `TRUE`, show individual change scores and lines.
#' @param y_lims Optional numeric vector of length two specifying the displayed
#'   y-axis limits.
#'
#' @details
#' Intake and discharge are taken from the first and last `episode_session`
#' within each client episode. Episodes with a missing intake or discharge
#' outcome are omitted. Error bars show the mean plus or minus 1.96 standard
#' errors; they are omitted when a cohort–episode group has fewer than two
#' usable clients.
#'
#' @return A `ggplot2` plot.
#' @export
plot_cohort_change <- function(
    data,
    max_episodes = 3,
    higher_is_better = TRUE,
    show_individuals = TRUE,
    y_lims = NULL
) {
  cols_validate(
    data,
    required = c(
      "client_id", "episode_id", "episode_session",
      "outcome", "n_episodes"
    )
  )

  if (
    length(max_episodes) != 1L ||
    !is.numeric(max_episodes) ||
    is.na(max_episodes) ||
    !is.finite(max_episodes) ||
    max_episodes < 1 ||
    max_episodes != floor(max_episodes)
  ) {
    stop("`max_episodes` must be a positive whole number.", call. = FALSE)
  }

  if (!is.null(y_lims) &&
      (length(y_lims) != 2L ||
       !is.numeric(y_lims) ||
       anyNA(y_lims) ||
       y_lims[1] >= y_lims[2])) {
    stop("`y_lims` must contain two increasing numbers.", call. = FALSE)
  }

  if (anyNA(data[c(
    "client_id", "episode_id", "episode_session", "n_episodes"
  )])) {
    stop(
      "Client, episode, session, and episode-count identifiers cannot be missing.",
      call. = FALSE
    )
  }

  # Retain the requested episode cohorts.
  data <- data[
    data$n_episodes <= max_episodes,
    ,
    drop = FALSE
  ]

  if (nrow(data) == 0L) {
    stop("No observations remain after filtering cohorts.", call. = FALSE)
  }

  # Order sessions before identifying intake and discharge.
  data <- data[
    order(data$client_id, data$episode_id, data$episode_session),
    ,
    drop = FALSE
  ]

  episode_list <- split(
    data,
    list(data$client_id, data$episode_id),
    drop = TRUE
  )

  change_list <- lapply(episode_list, function(x) {
    baseline <- x$outcome[1L]
    final <- x$outcome[nrow(x)]

    change <- if (higher_is_better) {
      final - baseline
    } else {
      baseline - final
    }

    data.frame(
      client_id = x$client_id[1L],
      episode_id = x$episode_id[1L],
      n_episodes = x$n_episodes[1L],
      change = change
    )
  })

  change_data <- do.call(rbind, change_list)
  rownames(change_data) <- NULL

  # A change score requires both an intake and a discharge outcome.
  change_data <- change_data[
    !is.na(change_data$change),
    ,
    drop = FALSE
  ]

  if (nrow(change_data) == 0L) {
    stop(
      "No episodes have non-missing intake and discharge outcomes.",
      call. = FALSE
    )
  }

  summary_list <- split(
    change_data,
    list(change_data$n_episodes, change_data$episode_id),
    drop = TRUE
  )

  mean_change <- lapply(summary_list, function(x) {
    n <- nrow(x)
    mean_x <- mean(x$change)
    se_x <- if (n >= 2L) stats::sd(x$change) / sqrt(n) else NA_real_

    data.frame(
      n_episodes = x$n_episodes[1L],
      episode_id = x$episode_id[1L],
      n = n,
      mean_change = mean_x,
      lower_ci = mean_x - 1.96 * se_x,
      upper_ci = mean_x + 1.96 * se_x
    )
  })

  mean_change <- do.call(rbind, mean_change)
  rownames(mean_change) <- NULL
  ci_data <- mean_change[mean_change$n >= 2L, , drop = FALSE]

  cohort_labels <- function(x) paste0(x, "-episode cohort")

  p <- ggplot2::ggplot(
    change_data,
    ggplot2::aes(x = episode_id, y = change)
  )

  if (show_individuals) {
    p <- p +
      ggplot2::geom_line(
        ggplot2::aes(group = client_id),
        colour = "grey65",
        linewidth = 0.30,
        alpha = 0.15
      ) +
      ggplot2::geom_point(
        colour = "grey55",
        size = 0.75,
        alpha = 0.18
      )
  }

  subtitle <- if (show_individuals) {
    paste(
      "Thin lines represent individual clients;",
      "points and error bars represent mean change and 95% confidence intervals"
    )
  } else {
    "Points and error bars represent mean change and 95% confidence intervals"
  }

  p +
    ggplot2::geom_hline(
      yintercept = 0,
      colour = "grey45",
      linewidth = 0.40,
      linetype = "dashed"
    ) +
    ggplot2::geom_errorbar(
      data = ci_data,
      ggplot2::aes(
        x = episode_id,
        ymin = lower_ci,
        ymax = upper_ci
      ),
      inherit.aes = FALSE,
      width = 0.10,
      linewidth = 0.55,
      colour = "#2C3E50"
    ) +
    ggplot2::geom_line(
      data = mean_change,
      ggplot2::aes(
        x = episode_id,
        y = mean_change,
        group = 1
      ),
      inherit.aes = FALSE,
      colour = "#2C3E50",
      linewidth = 1.10,
      lineend = "round"
    ) +
    ggplot2::geom_point(
      data = mean_change,
      ggplot2::aes(x = episode_id, y = mean_change),
      inherit.aes = FALSE,
      colour = "#2C3E50",
      size = 2.50
    ) +
    ggplot2::facet_wrap(
      ggplot2::vars(n_episodes),
      nrow = 1,
      scales = "free_x",
      labeller = ggplot2::labeller(n_episodes = cohort_labels)
    ) +
    ggplot2::scale_x_continuous(
      breaks = seq_len(max_episodes),
      expand = ggplot2::expansion(mult = c(0.10, 0.10))
    ) +
    ggplot2::coord_cartesian(ylim = y_lims) +
    ggplot2::labs(
      x = "Treatment episode",
      y = "Episode change score",
      title = "Outcome change across treatment episodes",
      subtitle = subtitle,
      caption = "Positive scores indicate improvement."
    ) +
    ggthemes::theme_few(base_size = 11) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(
        colour = "grey90", linewidth = 0.20
      ),
      panel.border = ggplot2::element_rect(
        colour = "grey35", fill = NA, linewidth = 0.40
      ),
      panel.spacing = grid::unit(0.9, "lines"),
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold", size = 10),
      axis.title = ggplot2::element_text(size = 10.5),
      axis.text = ggplot2::element_text(size = 9),
      plot.title = ggplot2::element_text(face = "bold", size = 13),
      plot.subtitle = ggplot2::element_text(
        size = 10, colour = "grey25"
      ),
      plot.caption = ggplot2::element_text(
        size = 9, colour = "grey35", hjust = 0
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot"
    )
}

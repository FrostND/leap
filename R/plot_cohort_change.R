

plot_cohort_change <- function(
    data,
    client = "client_id",
    episode = "episode_id",
    episode_session = "episode_session",
    outcome = "outcome",
    episode_count = "n_episodes",
    max_episodes = 3,
    higher_is_better = TRUE,
    show_individuals = TRUE,
    y_lims = NULL
) {

  required_columns <- c(
    client,
    episode,
    episode_session,
    outcome,
    episode_count
  )

  missing_columns <- setdiff(required_columns, names(data))

  if (length(missing_columns) > 0L) {
    stop(
      "Missing required column(s): ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  # Retain the requested episode cohorts.
  data <- data[data[[episode_count]] <= max_episodes,, drop = FALSE]

  # Ensure sessions are ordered correctly within episodes.
  data <- data[order(data[[client]], data[[episode]], data[[episode_session]]),, drop = FALSE]

  # Split the session-level data into client episodes.
  episode_list <- split(
    data,
    list(
      data[[client]],
      data[[episode]]
    ),
    drop = TRUE
  )

  # Calculate one change score per client episode.
  change_list <- lapply(episode_list, function(episode_data) {

    baseline <- episode_data[[outcome]][1]
    final <- episode_data[[outcome]][nrow(episode_data)]

    change <- if (higher_is_better) {
      final - baseline
    } else {
      baseline - final
    }

    data.frame(
      client_id = episode_data[[client]][1],
      episode_id = episode_data[[episode]][1],
      n_episodes = episode_data[[episode_count]][1],
      n_sessions = nrow(episode_data),
      baseline = baseline,
      final = final,
      change = change
    )
  })

  change_data <- do.call(
    what = rbind,
    args = change_list
  )

  rownames(change_data) <- NULL

  # Summarize mean change within each cohort and episode.
  summary_list <- split(
    change_data,
    list(
      change_data$n_episodes,
      change_data$episode_id
    ),
    drop = TRUE
  )

  mean_change <- lapply(summary_list, function(x) {

    n <- sum(!is.na(x$change))
    mean_x <- mean(x$change, na.rm = TRUE)
    sd_x <- stats::sd(x$change, na.rm = TRUE)
    se_x <- sd_x / sqrt(n)

    data.frame(
      n_episodes = x$n_episodes[1],
      episode_id = x$episode_id[1],
      n = n,
      mean_change = mean_x,
      lower_ci = mean_x - 1.96 * se_x,
      upper_ci = mean_x + 1.96 * se_x
    )
  })

  mean_change <- do.call(
    what = rbind,
    args = mean_change
  )

  rownames(mean_change) <- NULL

  cohort_labels <- function(x) {
    paste0(
      x,
      ifelse(x == 1, "-episode cohort", "-episode cohort")
    )
  }

  p <- ggplot2::ggplot(
    change_data,
    ggplot2::aes(
      x = episode_id,
      y = change
    )
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

  p +
    ggplot2::geom_hline(
      yintercept = 0,
      colour = "grey45",
      linewidth = 0.40,
      linetype = "dashed"
    ) +
    ggplot2::geom_errorbar(
      data = mean_change,
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
      ggplot2::aes(
        x = episode_id,
        y = mean_change
      ),
      inherit.aes = FALSE,
      colour = "#2C3E50",
      size = 2.50
    ) +
    ggplot2::facet_wrap(
      ggplot2::vars(n_episodes),
      nrow = 1,
      scales = "free_x",
      labeller = ggplot2::labeller(
        n_episodes = cohort_labels
      )
    ) +
    ggplot2::scale_x_continuous(
      breaks = seq_len(max_episodes),
      expand = ggplot2::expansion(mult = c(0.10, 0.10))
    ) +
    ggplot2::coord_cartesian(
      ylim = y_lims
    ) +
    ggplot2::labs(
      x = "Treatment episode",
      y = "Episode change score",
      title = "Outcome change across treatment episodes",
      subtitle = paste(
        "Thin lines represent individual clients;",
        "points and error bars represent mean change and 95% confidence intervals"
      ),
      caption = "Positive scores indicate improvement."
    ) +
    ggthemes::theme_few(
      base_size = 11,
      base_family = "Times"
    ) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(
        colour = "grey90",
        linewidth = 0.20
      ),
      panel.border = ggplot2::element_rect(
        colour = "grey35",
        fill = NA,
        linewidth = 0.40
      ),
      panel.spacing = grid::unit(0.9, "lines"),
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(
        face = "bold",
        size = 10,
        margin = ggplot2::margin(b = 5)
      ),
      axis.title = ggplot2::element_text(
        size = 10.5
      ),
      axis.text = ggplot2::element_text(
        size = 9
      ),
      plot.title = ggplot2::element_text(
        face = "bold",
        size = 13,
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        size = 10,
        colour = "grey25",
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        size = 9,
        colour = "grey35",
        hjust = 0,
        margin = ggplot2::margin(t = 8)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot"
    )
}

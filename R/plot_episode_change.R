#' Plot change across treatment episodes
#'
#' Plots episode-level change scores across successive treatment episodes.
#' Individual client profiles may be displayed in the background, while mean
#' change scores and 95% confidence intervals for each episode number are
#' displayed in the foreground.
#'
#' @param data A data frame containing episode-level summaries produced by
#'   [episode_slopes()]. The data must contain `client_id`, `episode_id`,
#'   `n_episodes`, and `change`.
#' @param cohort Character string specifying the client cohort to display.
#'   Must be one of `"all"` or `"multiple"`. `"all"` includes all clients,
#'   whereas `"multiple"` restricts the plot to clients with more than one
#'   treatment episode. Defaults to `"all"`.
#' @param max_episodes Optional numeric value specifying the highest treatment
#'   episode to display. For example, `max_episodes = 3` displays Episodes 1
#'   through 3. Clients with additional episodes may still contribute
#'   observations from earlier episodes. Defaults to `NULL`.
#' @param show_individuals Logical indicating whether individual client change
#'   profiles and observations should be displayed. Defaults to `TRUE`.
#' @param y_lims Optional numeric vector of length two specifying the displayed
#'   y-axis limits. Defaults to `NULL`.
#'
#' @return
#' A `ggplot` object showing change scores across treatment episodes.
#'
#' @details
#' `plot_episode_change()` operates on episode-level data produced by
#' [episode_slopes()]. Each row represents one treatment episode for a client,
#' and `change` represents the difference between the first and final outcome
#' observations within that episode.
#'
#' The direction of change is determined when [episode_slopes()] is called.
#' When episode slopes are calculated with `higher_is_better = TRUE`, positive
#' change scores indicate improvement. When `higher_is_better = FALSE`, the
#' direction of change is reversed so that positive values continue to
#' represent improvement.
#'
#' For each treatment episode number, the function calculates the mean change
#' score and an approximate 95% confidence interval:
#'
#' \deqn{
#' \overline{\mathrm{Change}}_j
#' \mathbin{\pm}
#' 1.96 \times \mathrm{SE}_j
#' }
#'
#' where \(j\) denotes treatment episode number.
#'
#' When `show_individuals = TRUE`, observations from the same client are
#' connected across episodes to show within-client patterns of change.
#'
#' The composition of the sample may differ across episode numbers because
#' only clients who return for additional treatment contribute observations
#' to later episodes. Consequently, differences across episode numbers should
#' not necessarily be interpreted as within-client change.
#'
#' @examples
#' \dontrun{
#' # Calculate episode-level slopes and change scores
#' episodes <- episode_slopes(treatment_data)
#'
#' # Plot change across all treatment episodes
#' plot_episode_change(data = episodes)
#'
#' # Restrict to clients with multiple treatment episodes
#' plot_episode_change(data = episodes, cohort = "multiple")
#'
#' # Display only the first three treatment episodes
#' plot_episode_change(data = episodes, cohort = "multiple", max_episodes = 3)
#'
#' # Hide individual client profiles
#' plot_episode_change(data = episodes, show_individuals = FALSE)
#'
#' # Reverse the direction of change for an outcome where lower is better
#' episodes <- episode_slopes(treatment_data, higher_is_better = FALSE)
#'
#' plot_episode_change(episodes)
#' }
#'
#' @seealso
#' [episode_slopes()],
#' [plot_episode_curves()]
#'
#' @export
#' @export
plot_episode_change <- function(
    data,
    cohort = c("all", "multiple"),
    max_episodes = NULL,
    show_individuals = TRUE,
    y_lims = NULL
) {

  cohort <- match.arg(cohort)

  # Validate episode-level data.
  cols_validate(
    data,
    required = c(
      "client_id",
      "episode_id",
      "n_episodes",
      "change"
    )
  )

  # Define analytic cohort.
  data <- filter_cohorts(data = data, cohort = cohort)

  # Optionally restrict episodes displayed.
  if (!is.null(max_episodes)) {
    data <- data[data$episode_id <= max_episodes, ,drop = FALSE]
  }

  # Summarize change by episode number.
  episode_groups <- split(data, f = data$episode_id, drop = TRUE)

  summary_list <- lapply(episode_groups, function(x) {

    n <- sum(!is.na(x$change))
    mean_change <- mean(x$change, na.rm = TRUE)

    se_change <- stats::sd(
      x$change,
      na.rm = TRUE
    ) / sqrt(n)

    data.frame(
      episode_id = x$episode_id[1],
      n = n,
      mean_change = mean_change,
      lower_ci = mean_change - 1.96 * se_change,
      upper_ci = mean_change + 1.96 * se_change
    )
  })

  summary_data <- do.call(
    what = rbind,
    args = summary_list
  )

  rownames(summary_data) <- NULL

  # Plot episode-level change.
  p <- ggplot2::ggplot(
    data,
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
        alpha = 0.12
      ) +
      ggplot2::geom_point(
        colour = "grey55",
        size = 0.70,
        alpha = 0.16
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
      data = summary_data,
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
      data = summary_data,
      ggplot2::aes(
        x = episode_id,
        y = mean_change,
        group = 1
      ),
      inherit.aes = FALSE,
      colour = "#2C3E50",
      linewidth = 1.10
    ) +
    ggplot2::geom_point(
      data = summary_data,
      ggplot2::aes(
        x = episode_id,
        y = mean_change
      ),
      inherit.aes = FALSE,
      colour = "#2C3E50",
      size = 2.6
    ) +
    ggplot2::scale_x_continuous(
      breaks = sort(unique(data$episode_id))
    ) +
    ggplot2::coord_cartesian(
      ylim = y_lims
    ) +
    ggplot2::labs(
      x = "Treatment episode",
      y = "Episode change score",
      title = "Mean change across treatment episodes",
      caption = "Positive values indicate improvement."
    ) +
    ggthemes::theme_few(
      base_size = 11,
      base_family = "Times"
    )
}

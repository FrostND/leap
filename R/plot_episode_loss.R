#' Plot change between treatment episodes
#'
#' Visualizes changes in outcome scores between the end of one treatment
#' episode and the beginning of the next. Each line connects a client's
#' discharge score from one episode with their intake score at the subsequent
#' episode. Horizontal spacing may be scaled to reflect the amount of time
#' elapsed between episodes.
#'
#' @param data A data frame containing between-episode summaries produced by
#'   [episode_breaks()]. The data must contain `client_id`, `prior_episode`,
#'   `next_episode`, `prior_discharge`, `next_intake`, `days_between`, and
#'   `bad_enough_level`.
#' @param max_episodes Optional numeric value specifying the highest treatment
#'   episode to display. For example, `max_episodes = 3` retains transitions
#'   ending at Episodes 2 and 3. Defaults to `NULL`.
#' @param show_individuals Logical indicating whether individual between-episode
#'   transitions should be displayed. Defaults to `TRUE`.
#' @param show_time Logical indicating whether horizontal spacing between
#'   discharge and subsequent intake observations should reflect elapsed time
#'   between treatment episodes. Defaults to `TRUE`.
#' @param y_lims Optional numeric vector of length two specifying the displayed
#'   y-axis limits. Defaults to `NULL`.
#'
#' @return
#' A `ggplot` object showing outcome change between successive treatment
#' episodes.
#'
#' @details
#' `plot_episode_breaks()` operates on transition-level data produced by
#' [episode_breaks()]. Each row represents the interval between two consecutive
#' treatment episodes for a client.
#'
#' For each transition, the plot connects the outcome score observed at
#' discharge from the prior episode with the outcome score observed at intake
#' to the subsequent episode. These transitions provide a visual representation
#' of between-episode change:
#'
#' \deqn{
#' \mathrm{Break}_{ij}
#' =
#' Y_{ij,\mathrm{discharge}}
#' -
#' Y_{i,j+1,\mathrm{intake}}
#' }
#'
#' when higher outcome scores indicate better functioning. The direction of
#' this quantity is determined upstream by [episode_breaks()], such that
#' positive values of `bad_enough_level` represent deterioration between
#' treatment episodes.
#'
#' When `show_time = TRUE`, the horizontal distance between discharge and
#' subsequent intake is scaled according to `days_between`. This provides a
#' visual indication of the relative amount of time separating treatment
#' episodes while preventing unusually long intervals from dominating the
#' horizontal scale. Horizontal distance should therefore be interpreted as
#' relative rather than as a literal calendar-time axis.
#'
#' When `show_time = FALSE`, a common horizontal distance is used for all
#' transitions, emphasizing the magnitude and direction of between-episode
#' change rather than the duration of the treatment break.
#'
#' Only clients with two or more treatment episodes can contribute
#' between-episode transitions. Consequently, unlike functions that operate
#' on session- or episode-level data, a separate client cohort restriction is
#' not required.
#'
#' @examples
#' \dontrun{
#' # Calculate between-episode change
#' breaks <- episode_breaks(treatment_data)
#'
#' # Plot between-episode transitions
#' plot_episode_breaks(data = breaks)
#'
#' # Use equal spacing between treatment episodes
#' plot_episode_breaks(data = breaks, show_time = FALSE)
#'
#' # Display transitions involving only the first three episodes
#' plot_episode_breaks(data = breaks, max_episodes = 3)
#'
#' # Hide individual transitions
#' plot_episode_breaks(data = breaks, show_individuals = FALSE)
#' }
#'
#' @seealso
#' [episode_breaks()],
#' [plot_episode_change()],
#' [plot_episode_curves()]
#'
#' @export

plot_episode_loss <- function(
    data,
    max_episodes = NULL,
    show_individuals = TRUE,
    show_time = TRUE,
    y_lims = NULL
) {

  # Validate episode-break data.
  cols_validate(
    data,
    required = c(
      "client_id",
      "prior_episode",
      "next_episode",
      "prior_discharge",
      "next_intake",
      "days_between",
      "bad_enough_level"
    )
  )

  # Optionally restrict transitions displayed.
  if (!is.null(max_episodes)) {
    data <- data[data$next_episode <= max_episodes, ,drop = FALSE]
  }

  # Scale horizontal break width to elapsed time.
  if (show_time) {

    max_gap <- max(data$days_between,na.rm = TRUE)

    data$gap_width <- 0.15 + 0.55 * (data$days_between / max_gap)

  } else {

    data$gap_width <- 0.35
  }

  data$x_prior <- data$prior_episode
  data$x_next <- data$prior_episode + data$gap_width

  # Individual between-episode declines.
  p <- ggplot2::ggplot(data)

  if (show_individuals) {

    p <- p +
      ggplot2::geom_segment(
        ggplot2::aes(
          x = x_prior,
          xend = x_next,
          y = prior_discharge,
          yend = next_intake
        ),
        colour = "grey65",
        linewidth = 0.35,
        alpha = 0.15
      )
  }

  p +
    ggplot2::geom_point(
      ggplot2::aes(
        x = x_prior,
        y = prior_discharge
      ),
      colour = "grey45",
      size = 1
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        x = x_next,
        y = next_intake
      ),
      colour = "grey45",
      size = 1
    ) +
    ggplot2::scale_x_continuous(
      breaks = sort(unique(data$prior_episode)),
      labels = function(x) {
        paste("Episode", x)
      }
    ) +
    ggplot2::coord_cartesian(
      ylim = y_lims
    ) +
    ggplot2::labs(
      x = "Treatment episode transition",
      y = "Outcome score",
      title = "Outcome change between treatment episodes",
      subtitle = paste(
        "Lines connect discharge from one episode with intake at the next;",
        "horizontal spacing reflects elapsed time between episodes."
      )
    ) +
    theme_minimal(
      base_size = 11,
      base_family = "Times"
    )
}

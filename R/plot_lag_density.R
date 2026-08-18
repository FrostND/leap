
#' Visualize the distribution of between-session gaps and evaluate candidate episode delimiters.
#'
#' Displays a kernel density estimate of the number of days between consecutive
#' treatment sessions. The plot can be used to inspect the empirical
#' distribution of session gaps and evaluate potential thresholds for
#' delimiting treatment episodes.
#'
#' @param data A data frame containing session-level treatment records.
#' @param lag Character string specifying the session-lag variable.
#'   Defaults to `"session_lag"`.
#' @param delimiter Optional numeric value indicating a proposed episode
#'   delimiter in days. When supplied, a vertical dashed line is added at the
#'   specified value. Defaults to `NULL`.
#' @param smooth Numeric smoothing multiplier passed to the `adjust` argument
#'   of [ggplot2::geom_density()]. Values greater than `1` produce a smoother
#'   density estimate, whereas values less than `1` reveal more local
#'   variation. Defaults to `1.5`.
#'
#' @return
#' A `ggplot` object displaying the density of positive between-session gaps.
#'
#' @details
#' Observations with missing session lags or session lags less than or equal to
#' zero are excluded before plotting.
#'
#' The function is intended primarily as an exploratory tool for evaluating
#' potential episode boundaries. A proposed delimiter can be displayed using
#' the `delimiter` argument to compare an operational threshold with the
#' observed distribution of session gaps.
#'
#' The amount of smoothing can be controlled with `smooth`. Because
#' between-session gaps are often right-skewed, modest additional smoothing may
#' help reveal broad distributional patterns. Excessive smoothing, however, may
#' obscure distinct gap regimes or multimodality.
#'
#' @examples
#' \dontrun{
#' # Plot the distribution of session gaps
#' plot_breaks_density(data)
#'
#' # Display a proposed 90-day episode delimiter
#' plot_break_density(data, delimiter = 90)
#'
#' # Increase density smoothing
#' plot_breaks_density(data, delimiter = 90, smooth = 2)
#' }
#'
#' @seealso
#' [add_session_lag()],
#' [add_episode_id()]
#'
#' @export
plot_lag_density <- function(data, delimiter = NULL, smooth = 1.5) {

  cols_validate(data, required = c("session_lag"))

  df <- data[!is.na(data$session_lag) & data$session_lap > 0, ,drop = FALSE]

  p <- ggplot(df, aes(x = data$session_lag)) +
    geom_density(
      adjust = smooth,
      fill = "grey85",
      colour = "grey20",
      linewidth = 0.7,
      alpha = 0.7
    ) +
    scale_x_continuous(
      breaks = scales::breaks_pretty(n = 7),
      expand = expansion(mult = c(0, 0.02))
    ) +
    coord_cartesian(
      xlim = c(0, 365)
    ) +
    labs(
      x = "Days between sessions",
      y = "Density",
      title = "Distribution of between-session gaps",
      subtitle = "Density of elapsed days between consecutive treatment sessions"
    ) +
   theme_bw(
      base_size = 11,
      base_family = "Times"
    ) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(
        colour = "grey90",
        linewidth = 0.20
      ),
      panel.border = element_rect(
        fill = NA,
        colour = "grey40",
        linewidth = 0.40
      ),
      axis.title = element_text(
        face = "plain"
      ),
      plot.title = element_text(
        face = "plain",
        size = 13
      ),
      plot.subtitle = element_text(
        size = 10,
        colour = "grey30",
        margin = margin(b = 10)
      ),
      plot.title.position = "plot"
    )

  if (!is.null(delimiter)) {
    p <- p +
      geom_vline(
        xintercept = delimiter,
        colour = "grey30",
        linetype = "dashed",
        linewidth = 0.65
      )
  }

  p
}

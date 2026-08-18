#' Build an episode-transition dataset
#'
#' Converts session-level treatment data into an episode-transition dataset
#' containing one row for each pair of consecutive treatment episodes within a
#' client. The resulting data describe changes from the end of one episode to
#' the beginning of the next episode.
#'
#' @param data A data frame containing longitudinal treatment-session records.
#' @param client Character string specifying the client identifier column.
#'   Defaults to `"client_id"`.
#' @param episode Character string specifying the treatment episode identifier
#'   column. Defaults to `"episode_id"`.
#' @param episode_session Character string specifying the session-within-episode
#'   column. Defaults to `"episode_session"`.
#' @param date Character string specifying the session date column. The column
#'   should inherit from class `Date`. Defaults to `"session_date"`.
#' @param outcome Character string specifying the outcome variable. Defaults to
#'   `"outcome"`.
#' @param higher_is_better Logical indicating the direction of favorable
#'   outcomes. When `TRUE`, positive values of `bad_enough_level` indicate that
#'   the client's outcome declined between the prior episode's discharge and
#'   the next episode's intake. When `FALSE`, the score difference is reversed
#'   so that positive values continue to indicate deterioration. Defaults to
#'   `TRUE`.
#'
#' @return A data frame containing one row per transition between consecutive
#'   treatment episodes. The returned variables are:
#'
#' \describe{
#'   \item{client_id}{Client identifier.}
#'   \item{prior_episode}{Identifier for the earlier treatment episode.}
#'   \item{next_episode}{Identifier for the subsequent treatment episode.}
#'   \item{prior_discharge}{Outcome score at the final session of the earlier
#'     episode.}
#'   \item{next_intake}{Outcome score at the first session of the subsequent
#'     episode.}
#'   \item{bad_enough_level}{Outcome deterioration between the prior discharge
#'     and subsequent intake. Positive values indicate worsening.}
#'   \item{days_between}{Number of days between the prior discharge and next
#'     intake.}
#'   \item{months_between}{Approximate number of months between episodes,
#'     calculated as `days_between / 30.44`.}
#'   \item{loss_per_month}{Outcome deterioration divided by the approximate
#'     number of months between episodes.}
#' }
#'
#' @details
#' Sessions are first ordered by client, episode, and session-within-episode.
#' Each treatment episode is then reduced to its first and final observations.
#' Consecutive episodes are paired within clients to create transition-level
#' records.
#'
#' When `higher_is_better = TRUE`, the bad-enough-level score is calculated as:
#'
#' \deqn{
#' \mathrm{BEL}_{ij}
#' =
#' Y_{i,j,\mathrm{discharge}}
#' -
#' Y_{i,j+1,\mathrm{intake}}
#' }
#'
#' When lower outcome scores indicate better functioning, setting
#' `higher_is_better = FALSE` reverses this calculation so that positive values
#' still represent deterioration between treatment episodes.
#'
#' Clients with only one treatment episode do not contribute transition-level
#' observations. If no clients have multiple episodes, the function returns an
#' empty data frame with the expected column structure.
#'
#' The `loss_per_month` variable should be interpreted cautiously. It assumes
#' that between-episode deterioration can be expressed as a rate over elapsed
#' time, even though no outcome measurements are observed during the interval.
#'
#' @examples
#' \dontrun{
#' transition_data <- episode_slopes(
#'   data = treatment_data,
#'   client = "client_id",
#'   episode = "episode_id",
#'   episode_session = "episode_session",
#'   date = "session_date",
#'   outcome = "outcome"
#' )
#'
#' head(transition_data)
#'
#' # For outcomes where lower scores indicate better functioning
#' transition_data <- episode_breaks(
#'   data = treatment_data,
#'   higher_is_better = FALSE
#' )
#' }
#'
#' @seealso [describe_episodes()], [plot_episode_change()]
#'
#' @export
episode_breaks <- function(data, higher_is_better = TRUE) {

  cols_validate(
    data,
    required = c(
      "client_id",
      "episode_id",
      "episode_session",
      "outcome",
      "session_date",
      "client_episode_id"
    )
  )

  # Order sessions within each client and episode.
  data <- order_sessions(data, by = "episode")

  # Split data into client-specific treatment episodes.
  eps_dfs <- split(data, f = data$client_episode_id, drop = TRUE)

  # Reduce each episode to intake and discharge observations.
  eps_summary <- lapply(eps_dfs, function(x) {

    first <- 1L
    last <- nrow(x)

    data.frame(
      client_id = x$client_id[first],
      episode_id = x$episode_id[first],
      intake_date = x$session_date[first],
      discharge_date = x$session_date[last],
      intake_score = x$outcome[first],
      discharge_score = x$outcome[last],
      n_sessions = nrow(x)
    )
  })

  eps_summary <- do.call(what = rbind, args = eps_summary)
  rownames(eps_summary) <- NULL

  eps_summary <- eps_summary[order(eps_summary$client_id, eps_summary$episode_id), ,drop = FALSE]

  # Split episode-level data by client.
  clt_list <- split(eps_summary, eps_summary$client_id, drop = TRUE)

  # Calculate differences between consecutive episodes.
  break_list <- lapply(clt_list, function(x) {

    if (nrow(x) < 2L) {
      return(NULL)
    }

    prior <- x[-nrow(x), , drop = FALSE]
    next_eps <- x[-1L, , drop = FALSE]

    score_loss <- if (higher_is_better) {
      prior$discharge_score - next_eps$intake_score
    } else {
      next_eps$intake_score - prior$discharge_score
    }

    days_between <- as.numeric(next_eps$intake_date - prior$discharge_date)

    data.frame(
      client_id = prior$client_id,
      prior_episode = prior$episode_id,
      next_episode = next_eps$episode_id,
      prior_discharge = prior$discharge_score,
      next_intake = next_eps$intake_score,
      bad_enough_level = score_loss,
      days_between = days_between,
      months_between = days_between / 30.44,
      loss_per_month = ifelse(
        days_between > 0,
        score_loss / (days_between / 30.44),
        NA_real_
      )
    )
  })

  break_list <- Filter(f = Negate(is.null), x = break_list)

  if (length(break_list) == 0L) {

    return(
      data.frame(
        client_id = character(),
        prior_episode = integer(),
        next_episode = integer(),
        prior_discharge = numeric(),
        next_intake = numeric(),
        bad_enough_level = numeric(),
        days_between = numeric(),
        months_between = numeric(),
        loss_per_month = numeric()
      )
    )
  }

  out <- do.call(what = rbind, args = break_list)
  rownames(out) <- NULL

  out
}

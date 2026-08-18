#' Describe treatment episodes
#'
#' Summarizes treatment episodes across clients using session-level
#' psychotherapy data. For each treatment episode number, the function reports
#' the number of clients contributing data, the total number of sessions,
#' average time between sessions, and average outcome score.
#'
#' @param data A data frame containing session-level treatment records. The
#'   data must contain `client_id`, `episode_id`, `session_lag`, and `outcome`.
#'
#' @return
#' A data frame containing one row per treatment episode number with the
#' following variables:
#'
#' \describe{
#'   \item{episode_id}{
#'   Treatment episode number.
#'   }
#'   \item{n_clients}{
#'   Number of unique clients contributing observations to the episode.
#'   }
#'   \item{n_sessions}{
#'   Total number of sessions observed in the episode.
#'   }
#'   \item{mean_session_lag}{
#'   Mean number of days between consecutive sessions within the episode.
#'   }
#'   \item{mean_outcome}{
#'   Mean outcome score across sessions within the episode.
#'   }
#' }
#'
#' @details
#' `describe_episodes()` provides sample-level descriptive statistics for
#' successive treatment episodes. For example, the row corresponding to
#' Episode 2 summarizes all clients who contributed a second treatment
#' episode.
#'
#' Because clients may attend different numbers of treatment episodes, the
#' number and composition of clients contributing observations may differ
#' across episode numbers. Statistics for later episodes should therefore not
#' be interpreted as repeated summaries of an identical client cohort.
#'
#' The function assumes that session lags and treatment episode identifiers
#' have already been derived. These variables can be created using
#' [add_session_lag()] and [add_episode_id()], or as part of the standard
#' episode-preparation workflow using [add_episode_vars()].
#'
#' Undefined session lags, including the first session observed for each
#' client, are excluded when calculating `mean_session_lag`.
#'
#' @examples
#' \dontrun{
#' # Prepare session-level episode data
#' df <- add_episode_vars(raw_data)
#'
#' # Summarize successive treatment episodes
#' describe_episodes(df)
#' }
#'
#' @seealso
#' [add_episode_vars()],
#' [add_session_lag()],
#' [add_episode_id()]
#'
#' @export
describe_episodes <- function(
  data,
  client = "client_id",
  episode = "episode_id",
  outcome = "outcome",
  date = "session_date"
) {
  # cols_validate(data, client, episode, date, outcome)

  rnd <- function(x) {
    round(x, digits = 2)
  }

  eps_list <- split(data, f = data[[episode]], drop = TRUE)

  stat_store <- vector(mode = "list", length = length(eps_list))
  names(stat_store) <- names(eps_list)

  for (name in names(eps_list)) {
    # Data for one episode number across clients
    df <- eps_list[[name]]

    session_lag <- df$session_lag
    session_lag[session_lag == 0] <- NA_real_

    # Calculate each client's episode duration in days.
    episode_duration <- tapply(df[[date]], df[[client]], function(x) {
      as.numeric(max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
    })

    stat_store[[name]] <- data.frame(
      episode_id = as.integer(name),
      n_clients = length(unique(df[[client]])),
      n_sessions = nrow(df),
      mean_sessions = rnd(mean(table(df[[client]]))),
      mean_duration_days = rnd(mean(episode_duration, na.rm = TRUE)),
      mean_lag_days = rnd(mean(session_lag, na.rm = TRUE)),
      mean_outcome = rnd(mean(df[[outcome]], na.rm = TRUE))
    )
  }

  out <- do.call(what = rbind, args = stat_store)
  rownames(out) <- NULL
  out
}

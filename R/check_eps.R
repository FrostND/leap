#' Check treatment episode data
#'
#' Performs a set of structural and data-quality checks on longitudinal
#' treatment episode data. The function summarizes sample characteristics,
#' evaluates missingness, verifies session ordering, and identifies potentially
#' problematic episode structures.
#'
#' @param data A data frame containing longitudinal treatment-session records.
#' @param client Character string specifying the client identifier column.
#'   Defaults to `"client_id"`.
#' @param episode Character string specifying the treatment episode identifier
#'   column. Defaults to `"episode_id"`.
#' @param session Character string specifying the session-within-episode column.
#'   Defaults to `"episode_session"`.
#' @param date Character string specifying the session date column. Defaults to
#'   `"session_date"`.
#' @param outcome Character string specifying the outcome variable. Defaults to
#'   `"outcome"`.
#'
#' @return A one-row data frame containing diagnostic information:
#'
#' \describe{
#'   \item{n_rows}{Total number of session records.}
#'   \item{n_clients}{Number of unique clients.}
#'   \item{n_episodes}{Number of unique client-by-episode combinations.}
#'   \item{n_missing}{Total number of missing values across the data frame.}
#'   \item{n_missing_outcome}{Number of missing outcome observations.}
#'   \item{n_missing_date}{Number of missing session dates.}
#'   \item{n_single_session}{Number of treatment episodes containing only one
#'     session.}
#'   \item{n_short_episode}{Number of treatment episodes containing four or
#'     fewer sessions.}
#'   \item{correctly_ordered}{Logical indicating whether observations are
#'     ordered by client, episode, and session-within-episode.}
#'   \item{sequential_sessions}{Logical indicating whether session numbering
#'     begins at 1 and proceeds sequentially within each episode.}
#'   \item{chronological_dates}{Logical indicating whether session dates occur
#'     in chronological order within treatment episodes.}
#' }
#'
#' @details
#' Required columns are first checked using [cols_standard()]. Treatment
#' episodes are then evaluated for common structural problems that may affect
#' episode-level analyses.
#'
#' Warnings are issued when:
#'
#' \itemize{
#'   \item outcome observations are missing;
#'   \item session dates are missing;
#'   \item records are not correctly ordered;
#'   \item session numbering is not sequential within episodes;
#'   \item session dates are not chronological within episodes;
#'   \item one-session episodes are present; or
#'   \item episodes contain four or fewer sessions.
#' }
#'
#' Episodes with four or fewer sessions are flagged because estimates of
#' within-episode growth may be unstable when based on relatively few
#' observations.
#'
#' The function does not modify the supplied data.
#'
#' @examples
#' \dontrun{
#' diagnostics <- check_episodes(
#'   data = treatment_data,
#'   client = "client_id",
#'   episode = "episode_id",
#'   session = "episode_session",
#'   date = "session_date",
#'   outcome = "outcome"
#' )
#'
#' diagnostics
#' }
#'
#' @seealso [describe_episodes()], [episode_slopes()]
#'
#' @export
check_eps <- function(
    data,
    client = "client_id",
    episode = "episode_id",
    session = "episode_session",
    date = "session_date",
    outcome = "outcome"
) {

  # Validate required columns.
  cols_validate(data, required = c(client, episode, session, date, outcome))

  # Basic counts
  n_rows <- nrow(data)
  n_clients <- length(unique(data[[client]]))
  n_episodes <- length(unique(data[[episode]]))

  # Missing counts
  n_missing <- sum(is.na(data))
  n_missing_outcome <- sum(is.na(data[[outcome]]))
  n_missing_date <- sum(is.na(data[[date]]))

  # Check observation ordering
  ordered_index <- order(data[[client]], data[[episode]], data[[session]])
  correctly_ordered <- identical(ordered_index, seq_len(nrow(data)))

  # Split into client-specific treatment episodes.
  eps_list <- split(data, list(data[[client]], data[[episode]]), drop = TRUE)

  # Episode-level session counts.
  sessions_per_episode <- vapply(eps_list, nrow, integer(1))
  n_single_session <- sum(sessions_per_episode == 1L)
  n_short_episode <- sum(sessions_per_episode <= 4L)

  # Check sequential session numbering within episodes.
  valid_episode_session <- vapply(eps_list, function(x) {
      identical(as.integer(x[[session]]), seq_len(nrow(x)))
    }, logical(1)
    )

  sequential_sessions <- all(valid_episode_session)

  # Check chronological ordering within episodes.
  valid_dates <- vapply(eps_list, function(x) {
      dates <- x[[date]]

      if (anyNA(dates)) {
        return(NA)
      }

      !is.unsorted(dates)
    },
    logical(1)
  )

  chronological_dates <- if (all(is.na(valid_dates))) {
    NA
  } else {
    all(valid_dates, na.rm = TRUE)
  }

  # Issue informative warnings.
  if (n_missing_outcome > 0L) {
    warning(
      n_missing_outcome,
      " missing outcome observation(s) detected.",
      call. = FALSE
    )
  }

  if (n_missing_date > 0L) {
    warning(
      n_missing_date,
      " missing session date(s) detected.",
      call. = FALSE
    )
  }

  if (!correctly_ordered) {
    warning(
      "Data are not ordered by client, episode, and episode session.",
      call. = FALSE
    )
  }

  if (!sequential_sessions) {
    warning(
      "At least one episode has non-sequential episode-session numbering.",
      call. = FALSE
    )
  }

  if (isFALSE(chronological_dates)) {
    warning(
      paste(
        "At least one episode contains session dates",
        "that are not in chronological order."
      ),
      call. = FALSE
    )
  }

  if (n_single_session > 0L) {
    warning(
      n_single_session,
      " episode(s) contain only one session.",
      call. = FALSE
    )
  }

  if (n_short_episode > 0L) {
    warning(
      n_short_episode,
      " episode(s) contain four or fewer sessions.",
      call. = FALSE
    )
  }

  data.frame(
    obs = n_rows,
    clients = n_clients,
    episodes = n_episodes,
    na_total = n_missing,
    na_outcomes = n_missing_outcome,
    na_dates = n_missing_date,
    correctly_ordered = correctly_ordered,
    sequential_sessions = sequential_sessions,
    chronological_dates = chronological_dates
  )
}

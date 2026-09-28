#' Check treatment episode data
#'
#' Performs a set of structural and data-quality checks on longitudinal
#' treatment episode data. The function summarizes sample characteristics,
#' evaluates missingness, verifies session ordering, and identifies potentially
#' problematic episode structures.
#'
#' @param data A data frame containing longitudinal treatment-session records.
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
#' diagnostics <- check_episodes(data = treatment_data)
#'
#' diagnostics
#' }
#'
#' @seealso [describe_episodes()], [episode_slopes()]
#'
#' @export
check_episodes <- function(data) {

  cols_validate(data, required = c("client_id", "episode_id", "episode_session", "session_date", "outcome"))

  # Basic counts
  n_rows <- nrow(data)
  n_clients <- length(unique(data$client_id))

  # Missing counts
  n_missing <- sum(is.na(data))
  n_missing_outcome <- sum(is.na(data$outcome))
  n_missing_date <- sum(is.na(data$session_date))

  # Check observation ordering
  ordered_index <- order(
    data$client_id,
    data$episode_id,
    data$episode_session
  )
  correctly_ordered <- identical(ordered_index, seq_len(n_rows))

  # Split into client-specific treatment episodes
  eps_list <- split(data,list(data$client_id, data$episode_id), drop = TRUE)
  n_episodes <- length(eps_list)

  # Episode-level session counts
  sessions_per_episode <- vapply(eps_list, nrow, integer(1))
  n_single_session <- sum(sessions_per_episode == 1L)
  n_short_episode <- sum(sessions_per_episode <= 4L)

  # Check sequential session numbering within episodes
  valid_episode_session <- vapply(eps_list, function(x) {
    identical(as.integer(x$episode_session), seq_len(nrow(x)))
  }, logical(1))

  sequential_sessions <- all(valid_episode_session)

  # Check chronological ordering within episodes
  valid_dates <- vapply(eps_list, function(x) {
    if (anyNA(x$session_date)) {
      return(NA)
    }

    !is.unsorted(x$session_date)
  }, logical(1))

  chronological_dates <- if (any(valid_dates == FALSE, na.rm = TRUE)) {
    FALSE
  } else if (anyNA(valid_dates)) {
    NA
  } else {
    TRUE
  }

  # Issue informative warnings
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
      "At least one episode contains session dates that are not in chronological order.",
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

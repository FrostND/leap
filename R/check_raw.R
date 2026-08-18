#' Check whether raw treatment data are ready for episode preparation
#'
#' Evaluates whether a raw longitudinal treatment dataset contains the
#' user-supplied variables required for episode construction and identifies
#' episode-related variables that have not yet been created.
#'
#' The function is intended as an initial diagnostic before running the
#' episode-preparation workflow.
#'
#' @param data A data frame containing longitudinal treatment-session records.
#' @param client Character string specifying the client identifier column.
#'   Defaults to `"client_id"`.
#' @param date Character string specifying the session date column.
#'   Defaults to `"session_date"`.
#' @param outcome Character string specifying the outcome variable.
#'   Defaults to `"outcome"`.
#'
#' @return A data frame describing the expected variables, whether each
#'   variable is present, and the recommended action when it is missing.
#'
#' \describe{
#'   \item{variable}{Conceptual role of the variable within the episode
#'     workflow.}
#'   \item{column}{Expected column name.}
#'   \item{type}{Whether the variable is required from the user or derived by
#'     episodeR.}
#'   \item{present}{Logical indicating whether the column is present in
#'     `data`.}
#'   \item{action}{Recommended action based on the current dataset.}
#' }
#'
#' @details
#' The function distinguishes between two types of variables:
#'
#' \itemize{
#'   \item \strong{Required variables} must be supplied by the user and include
#'   a client identifier, session date, and outcome variable.
#'   \item \strong{Derived variables} are created during episode preparation
#'   and include session lags, episode identifiers, session-within-episode
#'   numbers, client-episode identifiers, and episode counts.
#' }
#'
#' Missing derived variables are not treated as errors. Instead, the returned
#' diagnostic table identifies the episodeR function that can be used to create
#' each variable.
#'
#' Additional warnings are issued when client identifiers, session dates, or
#' outcome values contain missing observations. A warning is also issued when
#' the session date variable does not inherit from class `Date`.
#'
#' The function does not modify the supplied data.
#'
#' @examples
#' \dontrun{
#' check_raw(
#'   data = treatment_data,
#'   client = "client_id",
#'   date = "session_date",
#'   outcome = "outcome"
#' )
#' }
#'
#' @seealso
#' [check_eps()],
#' [add_session_lag()],
#' [add_episode_id()],
#' [add_episode_session()],
#' [add_client_episode_id()],
#' [add_episode_count()]
#'
#' @export
check_raw <- function(
    data,
    client = "client_id",
    date = "session_date",
    outcome = "outcome"
) {

  if (!is.data.frame(data)) {
    stop(
      "`data` must be a data frame.", call. = FALSE
    )
  }

  # Columns required from the user.
  required <- c(client = client, date = date, outcome = outcome)

  # Columns created during episode preparation.
  derived <- c(
    session_lag = "session_lag",
    episode_id = "episode_id",
    episode_session = "episode_session",
    client_episode_id = "client_episode_id",
    n_episodes = "n_episodes"
  )

  # Check required columns.
  required_present <- required %in% names(data)

  # Check derived columns.
  derived_present <- derived %in% names(data)

  # Build diagnostic table.
  out <- data.frame(
    variable = c(names(required), names(derived)),
    column = c(required, derived),
    type = c(rep("Required", length(required)), rep("Derived", length(derived))),
    present = c(required_present, derived_present), stringsAsFactors = FALSE
  )

  # Recommended actions.
  out$action <- NA_character_
  out$action[out$type == "Required" & !out$present] <- "Supply or specify this column"
  out$action[out$column == "session_lag" & !out$present] <- "Run add_session_lag()"
  out$action[out$column == "episode_id" & !out$present] <- "Run add_episode_id()"
  out$action[out$column == "episode_session" & !out$present] <- "Run add_episode_session()"
  out$action[out$column == "client_episode_id" & !out$present] <- "Run add_client_episode_id()"
  out$action[out$column == "n_episodes" & !out$present] <- "Run add_episode_count()"
  out$action[out$present] <- "Ready"

  # Additional structural checks.
  if (date %in% names(data)) {

    if (!inherits(data[[date]], "Date")) {
      warning(
        "`", date,
        "` is not stored as a Date variable.",
        call. = FALSE
      )
    }

    if (anyNA(data[[date]])) {
      warning(
        sum(is.na(data[[date]])),
        " missing session date(s) detected.",
        call. = FALSE
      )
    }
  }

  if (client %in% names(data) && anyNA(data[[client]])) {
    warning(
      sum(is.na(data[[client]])),
      " missing client identifier(s) detected.",
      call. = FALSE
    )
  }

  if (outcome %in% names(data) && anyNA(data[[outcome]])) {
    warning(
      sum(is.na(data[[outcome]])),
      " missing outcome observation(s) detected.",
      call. = FALSE
    )
  }

  rownames(out) <- NULL
  out
}

#' Standardize raw data column names
#'
#' Renames user-supplied variables to the standard naming convention used
#' throughout the leap package. Standardizing column names at the beginning of the
#' analysis workflow allows downstream functions to assume a consistent data
#' structure without requiring repeated specification of variable names.
#'
#' @param data A data frame containing psychotherapy session records.
#' @param client Character string specifying the client identifier column.
#' @param session Character string specifying the session identifier column.
#' @param outcome Character string specifying the outcome variable.
#' @param date Optional character string specifying the session date column.
#'   Defaults to `NULL`.
#'
#' @return
#' A data frame with standardized column names.
#'
#' \describe{
#'   \item{client_id}{Client identifier.}
#'   \item{session_id}{Session identifier.}
#'   \item{outcome}{Outcome variable.}
#'   \item{session_date}{Session date, if supplied.}
#' }
#'
#' @details
#' This function standardizes only the variables supplied by the user. Episode-
#' level variables such as `episode_id`, `episode_session`,
#' `client_episode_id`, and `n_episodes` are created later by episodeR during
#' episode preparation.
#'
#' Standardizing variable names once at the beginning of an analysis eliminates
#' the need to repeatedly specify column names in downstream functions.
#'
#' The function does not modify the contents of any variables; only their names
#' are changed.
#'
#' @examples
#' \dontrun{
#' data <- cols_standardize(
#'   data = treatment_data,
#'   client = "patient",
#'   session = "visit_number",
#'   outcome = "bhm_total",
#'   date = "visit_date"
#' )
#'
#' names(data)
#' }
#'
#' @seealso
#' [check_raw()],
#' [add_session_lag()],
#' [add_episode_id()]
#'
#' @export
cols_standard <- function(
    data,
    client,
    session,
    outcome,
    date = NULL
) {

  # Validate source variables.
  required <- c(client, session, outcome)

  if (!is.null(date)) {
    required <- c(required, date)
  }

  cols_validate(data, required = required)

  # Standardize core variable names.
  names(data)[names(data) == client] <- "client_id"
  names(data)[names(data) == session] <- "session_id"
  names(data)[names(data) == outcome] <- "outcome"

  if (!is.null(date)) {
    names(data)[names(data) == date] <- "session_date"
  }

  data
}

#' Order longitudinal session records
#'
#' Orders longitudinal treatment records either chronologically by client and
#' session date or structurally by client, treatment episode, and session
#' within episode.
#'
#' Proper ordering is important before calculating session lags, identifying
#' treatment episodes, or performing episode-level analyses.
#'
#' @param data A data frame containing session-level treatment records.
#' @param by Character string specifying how records should be ordered. Must be
#'   either `"date"` or `"episode"`. When `by = "date"`, records are ordered by
#'   `client_id` and `session_date`. When `by = "episode"`, records are ordered
#'   by `client_id`, `episode_id`, and `episode_session`. Defaults to `"date"`.
#'
#' @return
#' A data frame containing the original observations in the requested order.
#' Row names are reset after sorting.
#'
#' @details
#' When `by = "date"`, the function requires the standardized variables
#' `client_id` and `session_date`. This option is intended primarily for raw
#' data before treatment episodes have been identified.
#'
#' When `by = "episode"`, the function requires `client_id`, `episode_id`, and
#' `episode_session`. This option is intended for data that have already been
#' processed using episodeR.
#'
#' Missing values in any variable used for sorting result in an error because
#' they prevent unambiguous ordering of session records.
#'
#' @examples
#' \dontrun{
#' # Sort raw records chronologically within clients
#' data <- sort_sessions(
#'   data = treatment_data,
#'   by = "date"
#' )
#'
#' # Sort prepared data by treatment episode and session
#' data <- sort_sessions(
#'   data = treatment_data,
#'   by = "episode"
#' )
#'
#' # Compatible with the native R pipe
#' treatment_data |>
#'   sort_sessions(by = "date") |>
#'   add_session_lag()
#' }
#'
#' @seealso
#' [cols_standard()],
#' [add_session_lag()],
#' [add_episode_id()],
#' [add_episode_session()]
#'
#' @export
order_sessions <- function(data, by = c("date", "episode")) {

  by <- match.arg(by)

  vars <- switch(
    by,
    date = c("client_id", "session_date"),
    episode = c("client_id","episode_id", "episode_session")
  )

  cols_validate(data, required = vars)

  if (anyNA(data[vars])) {
    stop(
      paste(
        "Missing values detected in sorting variables.",
        "Please address missing values before sorting."
      ),
      call. = FALSE
    )
  }

  data <- data[do.call(order, data[vars]), ,drop = FALSE]
  rownames(data) <- NULL
  data
}



#' Calculates the number of days between psychotherapy sessions.
#'
#' Calculates the number of days elapsed between consecutive psychotherapy
#' sessions within each client. The first session for each client is assigned
#' a lag value of 0. Records should be sorted by client and session date prior
#' to calling this function.
#'
#' @param data A data frame containing longitudinal psychotherapy records.
#' @param client Character string specifying the name of the client identifier variable.
#' @param date Character string specifying the name of the session date variable. The
#' variable must be of class `Date`.
#'
#' @returns A data frame with an additional variable, `session_lag`, representing the number of days
#' since the previous session for each client.
#'
#' @details
#' Session lags are calculated separately for each client using the difference
#' between consecutive session dates. Incorrect results may occur if records
#' are not ordered chronologically within client. Use [order_sessions()] before
#' calculating session lags.
#'
#' @export
#'
#' @examples
#' # calculate session lags
#' sorted <- add_session_lag(data = sorted, client = "client_id", date = "session_date")
#'
#' # with native R pipe
#' sort_sessions(data = "unsorted", "client = "client_id", date = "session_id") |>
#'    add_session_lag(client = "client_id", date = "session_id")
#'
#' # with maggritr pipe
#' sort_sessions(data = "unsorted", "client = "client_id", date = "session_id") %>%
#'    add_session_lag(client = "client_id", date = "session_id")

add_session_lag <- function(data) {

  cols_validate(data, required = c("client_id", "session_date"))

  clts <- split(data, f = data$client_id)

  clts <- lapply(clts, function(x) {

    x$session_lag <- as.numeric(c(NA_real_, diff(x$session_date)))

    x
  })

  out <- do.call(rbind, clts)
  rownames(out) <- NULL

  out
}



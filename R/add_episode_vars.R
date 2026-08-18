#' Derive and build all treatment episode variables from raw longitudinal data.
#'
#' First sorts psychotherapy session records, calculates session lags, identifies
#' distinct treatment episodes per client, and assigns session numbers within
#' episodes, tabulates total episodes for each individual.
#'
#' This function provides a convenient wrapper around
#' [order_sessions()], [add_session_lag()], [add_episode_id()],
#' [add_episode_session()], and [add_episode_count()] for users who wish to
#' prepare episode-level data in a single step.
#'
#' @param data A data frame containing longitudinal psychotherapy records.
#' @param client Character string specifying the name of the client identifier
#'   variable.
#' @param date Character string specifying the name of the session date
#'   variable. The variable must be of class `Date`.
#' @param threshold Numeric value indicating the minimum number of days
#'   required to define a new treatment episode. Defaults to 90.
#'
#' @returns A data frame with the following additional variables:
#'   \describe{
#'     \item{session_lag}{Number of days since the previous session.}
#'     \item{episode_id}{Treatment episode identifier.}
#'     \item{episode_session}{Session number within treatment episode.}
#'   }
#'
#' @details
#' Treatment episodes are identified when the elapsed time between two
#' consecutive sessions meets or exceeds the specified threshold. By
#' default, a gap of 90 or more days indicates the beginning of a new
#' treatment episode.
#' @export
#'
#' @examples
#' # load package data
#' data("dat_unb")
#'
#' # identify treatment episodes
#' df <- add_episode_vars(data = dat_unb, client = "client_id", date = "session_date")
#'
#' # Use a custom episode threshold
#' df <- add_episode_vars(data = dat_unb, client = "client_id", date = "session_date", delimiter = 120)
#'
#'
add_episode_vars <- function(data, delimiter = 90) {
  data |>
    order_sessions() |>
    add_session_lag() |>
    add_episode_id(delimiter = delimiter) |>
    add_episode_session() |>
    add_episode_count() |>
    add_client_episode_id()
  }













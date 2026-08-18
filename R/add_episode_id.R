#' Identify unique treatment episodes
#'
#' Assigns a unique episode number to each session record within a client.
#' A new treatment episode is identified whenever the elapsed time between
#' consecutive sessions exceeds a user-defined threshold. By default,
#' treatment episodes are separated by 90 or more days, but this default
#' value can be altered by the user by specifying a different value
#' for the threshold argument.
#'
#' @param data A longitudinal data frame
#' @param client unique client identifier
#' @param session_lag lag time between sessions
#' @param threshold elapsed time used to demarcate treatment episodes
#'
#' @returns A data frame with an additional variable, `episode_id`,
#'  indicating the episode membership of each session.
#'
#' @details
#' This function assumes records are sorted chronologically within client and
#' that session lags have already been calculated. Users should first apply
#' [order_sessions()] followed by [add_session_lag()] before identifying
#' treatment episodes.
#'
#' @export
#'
#' @examples
#' out <- add_episode_id(data = df, client = "client_id", session_lag = "lag")
#'
#' with native R pipe
#' add_session_lag("client_id", "session_date") |>
#'     add_episode_id("client_id", "session_lag")
#'
#' # with miggrtir pipe
#' add_session_lag("client_id", "session_date") %>%
#'     add_episode_id("client_id", "session_lag")
#'

add_episode_id <- function(data, delimiter = 90) {
  # Validate required variables.
  cols_validate(data, required = c("client_id", "session_lag"))

  # Split data by client.
  clts <- split(data, f = data$client_id)

  # Identify treatment episodes within each client.
  clts <- lapply(clts, function(x) {
    new_episode <- !is.na(x$session_lag) & x$session_lag >= delimiter

    x$episode_id <- 1L + cumsum(new_episode)

    x
  })

  # Recombine client records.
  out <- do.call(rbind, clts)
  rownames(out) <- NULL

  out
}

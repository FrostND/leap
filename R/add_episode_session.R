#' Add session number within treatment episode
#'
#' Creates a consecutive session number within each client and treatment
#' episode. The resulting variable indicates the order of each session within
#' its episode.
#'
#' @param data A data frame containing session-level psychotherapy records.
#' @param client Character string specifying the name of the client identifier variable.
#' @param episode Character string specifying the name of the treatment episode identifier variable.
#' @param ... Additional arguments. Currently unused.
#'
#' @returns A data frame with an additional variable, `episode_session`, indicating
#'   the consecutive session number within each treatment episode.
#'
#' @details
#' This function assumes that records are already sorted chronologically within
#' client and episode. Use [order_sessions()] before identifying episodes and
#' adding episode-specific session numbers.
#'
#' @export
#'
#' @examples
#' out <- add_episode_session(data = dat_unb, client = "client_id", episode = "episode_id")
#'
#' # native R pipe
#' add_session_lag(data = dat_unb, client = "client_id", "session_date") |>
#'     add_episode_id(client = "client_id", session = "session_lag") |>
#'     add_episode_session(client = "client_id", episode = "episode_id")
#'
#' # magrittr pipe
#' dat_unb %>%
#'    add_session_lag(client_id, session_date) %>%
#'    add_episode_id(client_id, session_lag) %>%
#'    add_episode_session(client_id, episode_id)
#'
add_episode_session <- function(data, client, episode) {

  cols_validate(data, required = c("client_id", "episode_id"))

  out <- split(data, list(data$client_id, data$episode_id), drop = TRUE)

  out <- lapply(out, function(x) {x$episode_session <- seq_len(nrow(x))
    x})

  out <- do.call(rbind, out)
  rownames(out) <- NULL

  out
}







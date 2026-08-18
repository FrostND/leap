#' Add a unique client-episode identifier
#'
#' Creates a character identifier for each unique client-episode
#' combination by concatenating the client and episode identifiers.
#' This variable is useful for indexing episode-level random effects,
#' subsetting treatment episodes, and uniquely identifying observations
#' belonging to the same episode.
#'
#' @param data A data frame containing client and episode identifiers.
#' @param client Unquoted column name identifying clients.
#' @param episode Unquoted column name identifying treatment episodes.
#' @param name Name of the new identifier column. Defaults to
#'   `"client_episode_id"`.
#'
#' @return The input data frame with an additional character variable
#'   containing a unique identifier for each client-episode combination.
#'
#' @examples
#' df <- add_client_episode_id(
#'   data = df,
#'   client = client_id,
#'   episode = episode_id
#' )
#'
#' head(df$client_episode_id)
#'
#' @export

add_client_episode_id <- function(data) {

  cols_validate(data, required = c("client_id", "episode_id"))

  data$client_episode_id <- paste0(data$client_id, "_", data$episode_id)

  data
}

#' Classify clients by treatment attendance
#'
#' Creates client-level attendance variables based on the number of treatment
#' episodes attended.This variable can easily be used to subset clients
#' based based on the total number of episodes they attended.
#'
#' One variable is added to the data:
#'
#' \describe{
#'   \item{n_episodes}{Total number of treatment episodes attended by the client.}
#' }
#'
#' @param data A data frame containing psychotherapy session records.
#' @param client Character string specifying the name of the client identifier
#'   variable.
#' @param episode Character string specifying the name of the treatment
#'   episode identifier variable.
#'
#' @returns A data frame with two additional variables:
#'   \itemize{
#'     \item `n_episodes`
#'   }
#'
#' @details
#' This function assumes that treatment episodes have already been identified
#' using [add_episode_id()]
#'
#' @export
#'
add_episode_count <- function(data) {

  # Validate required variables.
  cols_validate(data, required = c("client_id", "episode_id"))

  # Count treatment episodes within each client.
  clts <- split(data, f = data$client_id)

  clts <- lapply(clts, function(x) {

    x$n_episodes <- max(x$episode_id, na.rm = TRUE)

    x
  })

  # Recombine client records.
  out <- do.call(rbind, clts)
  rownames(out) <- NULL

  out
}

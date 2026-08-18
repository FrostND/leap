#' Validate required columns
#'
#' Checks whether all required variables are present in a data frame. This
#' function is used internally to validate the structure of input data before
#' other package functions are evaluated.
#'
#' @param data A data frame containing the variables to validate.
#' @param required A character vector containing the names of required
#'   variables.
#'
#' @return
#' Invisibly returns `TRUE` when all required variables are present. If one or
#' more required variables are missing, the function stops with an informative
#' error identifying the missing variables.
#'
#' @details
#' This is an internal helper function used by other package functions to
#' perform consistent column validation. It is not intended to be called
#' directly by users.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' cols_validate(data, required = c("client_id", "episode_id")
#' )
#' }
cols_validate <- function(data, required) {

  missing <- setdiff(required, names(data))

  if (length(missing) > 0L) {
    stop(
      paste0(
        "Required variable(s) not found: ",
        paste(missing, collapse = ", "),
        ".\n\n",
        "Run the appropriate leap preparation function(s) ",
        "before calling this function."
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

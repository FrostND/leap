#' Filter treatment episodes by episode-level characteristics
#'
#' Filter longitudinal session records organized into treatment episodes
#' according to episode characteristics. Episodes may be selected by
#' episode number, number of sessions, or episode duration, and users
#' can control whether only matched episodes, prior episodes, or the
#' complete treatment history of matched clients are retained.
#'
#' @param data A data frame containing session-level treatment records. The
#'   data must contain `client_id`, `episode_id`, `episode_session`,
#'   `session_date`, and `client_episode_id`.
#' @param episode_num Optional numeric vector specifying treatment episode
#'   numbers to match. For example, `episode_num = 2` matches second treatment
#'   episodes, whereas `episode_num = c(2, 3)` matches Episodes 2 and 3.
#'   Defaults to `NULL`.
#' @param min_sessions Optional minimum number of sessions required for an
#'   episode to match. Defaults to `NULL`.
#' @param max_sessions Optional maximum number of sessions permitted for an
#'   episode to match. Defaults to `NULL`.
#' @param min_weeks Optional minimum episode duration in weeks required for an
#'   episode to match. Duration is calculated from the first to the last
#'   observed session date within each episode. Defaults to `NULL`.
#' @param max_weeks Optional maximum episode duration in weeks permitted for an
#'   episode to match. Defaults to `NULL`.
#' @param retain Character string specifying which session records to retain
#'   after matching episodes. Must be one of `"matched"`, `"through_match"`,
#'   or `"client"`. Defaults to `"matched"`.
#'
#' @return
#' A data frame containing session-level records corresponding to the requested
#' episode-level filtering criteria and retention strategy.
#'
#' @details
#' `filter_episodes()` first reduces the session-level data to one summary row
#' per client-specific treatment episode. For each episode, the function
#' calculates the number of sessions and episode duration in weeks. The
#' requested filtering criteria are then applied to these episode-level
#' summaries.
#'
#' Multiple criteria are combined using logical AND. For example,
#' `min_sessions = 4` and `max_weeks = 12` identify episodes containing at
#' least four sessions and lasting no more than 12 weeks.
#'
#' The `retain` argument determines how matched episodes are translated back
#' to the original session-level records:
#'
#' \describe{
#'   \item{`"matched"`}{
#'   Retains only treatment episodes that satisfy all specified criteria.
#'   }
#'   \item{`"through_match"`}{
#'   Retains matched episodes and all earlier treatment episodes for the same
#'   client, through the highest matched episode number.
#'   }
#'   \item{`"client"`}{
#'   Retains the complete treatment history of any client with at least one
#'   matching episode.
#'   }
#' }
#'
#' For example, if a client's Episode 3 satisfies the filtering criteria,
#' `retain = "matched"` retains only Episode 3, `retain = "through_match"`
#' retains Episodes 1 through 3, and `retain = "client"` retains all observed
#' episodes for that client.
#'
#' Episode identifiers are preserved and are not renumbered after filtering.
#' When all filtering arguments are left as `NULL`, every episode matches and
#' the complete input data are returned regardless of the retention strategy.
#'
#' @examples
#' \dontrun{
#' # Retain episodes containing at least four sessions
#' data_filt <- filter_episodes(
#'   data = tx_data,
#'   min_sessions = 4
#' )
#'
#' # Retain episodes containing 4 to 20 sessions
#' data_filt <- filter_episodes(
#'   data = tx_data,
#'   min_sessions = 4,
#'   max_sessions = 20
#' )
#'
#' # Retain episodes lasting at least eight weeks
#' # in duration
#' data_filt <- filter_episodes(
#'   data = tx_data,
#'   min_weeks = 8
#' )
#'
#' # Identify clients who reached Episode 3 and retain
#' # Episodes 1 through 3 for those clients
#' data_filt <- filter_episodes(
#'   data = tx_data,
#'   episode_num = 3,
#'   retain = "through_match"
#' )
#'
#' # Retain the complete treatment history of clients with a qualifying
#' # Episode 2 who attended a minimum of 5 sessions
#' data_filt <- filter_episodes(
#'   data = tx_data,
#'   episode_num = 2,
#'   min_sessions = 5,
#'   retain = "client"
#' )
#' }
#'
#' @seealso
#' [describe_episodes()]
#'
#' @export
filter_episodes <- function(
    data,
    episode_num = NULL,
    min_sessions = NULL,
    max_sessions = NULL,
    min_weeks = NULL,
    max_weeks = NULL,
    retain = c("matched", "through_match", "client")
) {

  retain <- match.arg(retain)

  # Validate required session-level variables.
  cols_validate(
    data,
    required = c(
      "client_id",
      "episode_id",
      "episode_session",
      "session_date",
      "client_episode_id"
    )
  )

  # split each into client-specific treatment episode.
  eps <- split(data, f = data$client_episode_id, drop = TRUE)


  eps <- lapply(eps, function(x) {
    data.frame(
      client_id = x$client_id[1],
      episode_id = x$episode_id[1],
      client_episode_id = x$client_episode_id[1],
      n_sessions = nrow(x),
      duration_weeks = as.numeric(max(x$session_date) - min(x$session_date)) / 7)
  })

  eps <- do.call(rbind, eps)

  rownames(eps) <- NULL

  # Apply episode-level filtering criteria.
  keep <- rep(TRUE, nrow(eps))

  if (!is.null(episode_num)) {
    keep <- keep & eps$episode_id %in% episode_num
  }

  if (!is.null(min_sessions)) {
    keep <- keep & eps$n_sessions >= min_sessions
  }

  if (!is.null(max_sessions)) {
    keep <- keep & eps$n_sessions <= max_sessions
  }

  if (!is.null(min_weeks)) {
    keep <- keep & eps$duration_weeks >= min_weeks
  }

  if (!is.null(max_weeks)) {
    keep <- keep & eps$duration_weeks <= max_weeks
  }

  matched <- eps[keep, , drop = FALSE]

  # Determine which session records to retain.
  if (retain == "matched") {

    ids <- matched$client_episode_id

  } else if (retain == "through_match") {

    ids <- unlist(
      lapply(
        split(matched, matched$client_id),
        function(x) {

          client <- x$client_id[1]

          max_episode <- max(x$episode_id)

          eps$client_episode_id[eps$client_id == client & eps$episode_id <= max_episode]
        }
      ),
      use.names = FALSE
    )

  } else {

    ids <- eps$client_episode_id[eps$client_id %in% matched$client_id]
  }

  data[data$client_episode_id %in% ids, ,drop = FALSE]
}


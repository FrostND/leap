#' Fit a multilevel treatment episode model
#'
#' Fits a linear mixed-effects model for session-level outcomes across repeated
#' treatment episodes. Models can estimate change within treatment episodes,
#' differences across successive episodes, and whether rates of within-episode
#' change vary across episode number.
#'
#' @param data A data frame containing session-level treatment records. The
#'   data must contain `client_id`, `episode_id`, `episode_session`, and
#'   `outcome`.
#' @param center Logical indicating whether session and episode number should
#'   be centered for interpretation. When `TRUE`, `episode_session` is centered
#'   at Session 1 and `episode_id` is centered at Episode 1. Defaults to `TRUE`.
#' @param cohort Character string specifying the client cohort to analyze.
#'   Must be one of `"all"` or `"multiple"`. `"all"` includes all clients,
#'   whereas `"multiple"` restricts the analysis to clients with more than one
#'   treatment episode. Defaults to `"all"`.
#' @param model Character string specifying the model to fit. Must be one of
#'   `"null"`, `"session"`, `"episode"`, or `"full"`. Defaults to `"null"`.
#'
#' @return
#' A fitted `lmerMod` object returned by [lme4::lmer()].
#'
#' @details
#' Sessions are nested within treatment episodes, which are nested within
#' clients. Four model specifications are available:
#'
#' \describe{
#'   \item{`"null"`}{Fits an unconditional random-intercept model with
#'   treatment episodes nested within clients.}
#'   \item{`"session"`}{Adds session within episode as a fixed effect and
#'   allows session trajectories to vary across clients and treatment
#'   episodes.}
#'   \item{`"episode"`}{Adds treatment episode number to the session model,
#'   allowing average outcome levels to differ across successive episodes.}
#'   \item{`"full"`}{Adds the interaction between session within episode and
#'   episode number, allowing rates of within-episode change to differ across
#'   successive episodes.}
#' }
#'
#' For models containing a session effect, the random-effects structure is:
#'
#' \deqn{
#' (\mathrm{Session} \mid \mathrm{client} / \mathrm{episode})
#' }
#'
#' which expands to random intercepts and random slopes for session at both
#' the client and client-by-episode levels.
#'
#' When `center = TRUE`, Session 1 and Episode 1 are coded as zero.
#' Consequently, the intercept represents the expected outcome at the first
#' session of the first treatment episode. In the `"full"` model, the session
#' coefficient represents the expected rate of change during Episode 1, and
#' the session-by-episode interaction represents change in the session
#' trajectory across successive treatment episodes.
#'
#' @examples
#' \dontrun{
#' # Unconditional model
#' m0 <- fit_lme(data = treatment_data, model = "null")
#'
#' # Model within-episode change
#' m1 <- fit_lme(data = treatment_data, model = "session")
#'
#' # Full model among clients with multiple treatment episodes
#' m2 <- fit_lme(data = treatment_data,  cohort = "multiple", model = "full")
#'
#' summary(m2)
#' }
#'
#' @seealso
#' [fit_sao()],
#' [fit_brms()],
#' [lme4::lmer()]
#'
#' @export
fit_lme <- function(
    data,
    center = TRUE,
    cohort = c("all", "multiple"),
    model = c("null", "session", "episode", "full")
) {

  # Match analysis options.
  cohort <- match.arg(cohort)
  model <- match.arg(model)

  # Validate required session-level variables.
  cols_validate(
    data,
    required = c(
      "client_id",
      "episode_id",
      "episode_session",
      "outcome"
    )
  )

  # Define the analytic cohort.
  data <- filter_cohorts(
    data = data,
    cohort = cohort
  )

  # Center predictors for interpretation.
  # Session: 0 = Session 1.
  # Episode: 0 = Episode 1.
  if (center) {

    data$ses_c <- data$episode_session - 1
    data$eps_c <- data$episode_id - 1

    formula <- switch(
      model,

      null =
        outcome ~ 1 +
        (1 | client_id / episode_id),

      session =
        outcome ~ ses_c +
        (ses_c | client_id / episode_id),

      episode =
        outcome ~ ses_c + eps_c +
        (ses_c | client_id / episode_id),

      full =
        outcome ~ ses_c * eps_c +
        (ses_c | client_id / episode_id)
    )

  } else {

    formula <- switch(
      model,

      null =
        outcome ~ 1 +
        (1 | client_id / episode_id),

      session =
        outcome ~ episode_session +
        (episode_session | client_id / episode_id),

      episode =
        outcome ~ episode_session + episode_id +
        (episode_session | client_id / episode_id),

      full =
        outcome ~ episode_session * episode_id +
        (episode_session | client_id / episode_id)
    )
  }

  lme4::lmer(
    formula = formula,
    data = data
  )
}

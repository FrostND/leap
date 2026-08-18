#' Fit a slopes-as-outcomes model
#'
#' Fits a multilevel slopes-as-outcomes (SAO) model in which episode-specific
#' rates of change are treated as the dependent variable. The function operates
#' on episode-level data produced by [episode_slopes()] and models variation in
#' treatment response across clients and treatment episodes.
#'
#' @param data A data frame of episode-level slope estimates produced by
#'   [episode_slopes()]. The data must contain `client_id`, `episode_id`,
#'   `n_sessions`, and `slope`.
#' @param center Logical indicating whether predictors should be centered prior
#'   to model estimation. When `TRUE`, `episode_id` is centered at the first
#'   treatment episode and `n_sessions` is centered at its sample mean.
#'   Defaults to `TRUE`.
#' @param model Character string specifying the model to fit. Must be one of
#'   `"null"`, `"session"`, `"episode"`, `"adjusted"`, or `"full"`.
#'   Defaults to `"null"`.
#'
#' @return
#' A fitted `lmerMod` object returned by [lme4::lmer()].
#'
#' @details
#' `fit_sao()` represents the second stage of a slopes-as-outcomes analysis.
#' Episode-specific rates of change must first be estimated using
#' [episode_slopes()]. Each row of the resulting data represents one treatment
#' episode, with repeated episodes nested within clients.
#'
#' Five model specifications are available:
#'
#' \describe{
#'   \item{`"null"`}{Fits an unconditional random-intercept model containing no
#'   episode-level predictors.}
#'   \item{`"session"`}{Adds the number of sessions within the treatment episode
#'   as a predictor of the episode-specific slope.}
#'   \item{`"episode"`}{Adds treatment episode number as a predictor of the
#'   episode-specific slope.}
#'   \item{`"adjusted"`}{Includes both treatment episode number and number of
#'   sessions as additive predictors.}
#'   \item{`"full"`}{Includes treatment episode number, number of sessions, and
#'   their interaction.}
#' }
#'
#' The full model can be expressed as:
#'
#' \deqn{
#' \mathrm{Slope}_{ij}
#' =
#' \beta_0
#' +
#' \beta_1(\mathrm{Episode}_{ij})
#' +
#' \beta_2(\mathrm{Sessions}_{ij})
#' +
#' \beta_3(\mathrm{Episode}_{ij} \times \mathrm{Sessions}_{ij})
#' +
#' u_{0i}
#' +
#' \varepsilon_{ij}
#' }
#'
#' where episode \(j\) is nested within client \(i\), and \(u_{0i}\) represents
#' a client-specific random intercept.
#'
#' When `center = TRUE`, treatment episode number is centered at the first
#' episode (`episode_id - 1`) and number of sessions is grand-mean centered.
#' Consequently, the intercept represents the expected treatment slope during
#' the first treatment episode for an episode of average length. Centering does
#' not affect the fit of a given model but changes the interpretation of its
#' intercept and, for models containing interactions, its lower-order
#' coefficients.
#'
#' Positive slope values represent improvement when the input to
#' [episode_slopes()] was constructed so that higher slope values indicate
#' improvement.
#'
#' @examples
#' \dontrun{
#' # Estimate one slope for each client treatment episode
#' slopes <- episode_slopes(treatment_data)
#'
#' # Fit the unconditional model
#' m0 <- fit_sao(data = slopes, model = "null")
#'
#' # Add treatment episode number
#' m1 <- fit_sao(data = slopes, model = "episode")
#'
#' # Fit the full model
#' m2 <- fit_sao(data = slopes, model = "full")
#'
#' summary(m2)
#' }
#'
#' @seealso
#' [episode_slopes()],
#' [compare_lme_fit()],
#' [fit_lme()]
#'
#' @export
fit_sao <- function(
    data,
    center = TRUE,
    cohort = c("all", "multiple"),
    model = c("null", "session", "episode", "adjusted", "full")
) {

  # match analysis options
  cohort <- match.arg(cohort)
  model <- match.arg(model)

  # validate required columns
  cols_validate(data, required = c("client_id", "episode_id", "n_sessions", "slope"))

  # define analytic cohort
  data <- filter_cohorts(data = data, cohort = cohort)

  # centered predictors
  # episode: 0 = episode 1
  # sessions: 0 = sample mean number of sessions
  if (center) {

    data$episode_c <- data$episode_id - 1
    data$n_sessions_c <- data$n_sessions - mean(data$n_sessions, na.rm = TRUE)

    formula <- switch(
      model,
      null = slope ~ 1 + (1 | client_id),
      session = slope ~ n_sessions_c + (1 | client_id),
      episode = slope ~ episode_c + (1 | client_id),
      adjusted = slope ~ episode_c + n_sessions_c + (1 | client_id),
      full = slope ~ episode_c * n_sessions_c + (1 | client_id)
    )

  } else {

    formula <- switch(
      model,
      null = slope ~ 1 + (1 | client_id),
      session = slope ~ n_sessions + (1 | client_id),
      episode = slope ~ episode_id + (1 | client_id),
      adjusted = slope ~ episode_id + n_sessions + (1 | client_id),
      full = slope ~ episode_id * n_sessions + (1 | client_id)
    )
  }

  lme4::lmer(formula, data = data)
}






#' Compare mixed-effects model fit
#'
#' Compares a set of fitted mixed-effects models using common model-fit and
#' diagnostic statistics. The function summarizes sample size, parameter count,
#' log-likelihood, information criteria, estimation method, singularity, and
#' convergence status for each model.
#'
#' @param models A named or unnamed list of fitted mixed-effects models that
#'   inherit from class `"merMod"`, such as models returned by
#'   [lme4::lmer()]. If the list is unnamed, model names are generated
#'   automatically.
#'
#' @return
#' A data frame with one row per model and the following variables:
#'
#' \describe{
#'   \item{model}{Model name.}
#'   \item{n_obs}{Number of observations used to fit the model.}
#'   \item{n_par}{Number of estimated model parameters.}
#'   \item{logLik}{Model log-likelihood.}
#'   \item{AIC}{Akaike information criterion.}
#'   \item{BIC}{Bayesian information criterion.}
#'   \item{REML}{Logical indicator of whether the model was estimated using
#'   restricted maximum likelihood.}
#'   \item{singular}{Logical indicator of whether the fitted model is singular.}
#'   \item{convergence}{Character indicator of model convergence status.}
#'   \item{message}{Convergence warning returned by `lme4`, if present.}
#' }
#'
#' @details
#' The function is intended to provide a compact comparison of alternative
#' mixed-effects model specifications. Lower AIC and BIC values generally
#' indicate better relative fit among models estimated on the same data.
#'
#' Singularity is evaluated using [lme4::isSingular()] with a tolerance of
#' `1e-4`. Convergence warnings are extracted from the model's optimizer
#' information and reported in the returned data frame.
#'
#' Models with different fixed-effects specifications should generally be
#' compared using maximum likelihood rather than restricted maximum likelihood.
#' Users should therefore consider fitting such models with `REML = FALSE`
#' before comparing likelihood-based fit statistics.
#'
#' @examples
#' \dontrun{
#' models <- list(
#'   random_intercept = mod_1,
#'   episode_intercept = mod_2,
#'   random_slope = mod_3
#' )
#'
#' compare_lme_fit(models)
#' }
#'
#' @seealso
#' [lme4::lmer()],
#' [lme4::isSingular()]
#'
#' @export
compare_lme_fit <- function(models) {

  if (!is.list(models)) {
    stop(
      "`models` must be a list of fitted lmer models.",
      call. = FALSE
    )
  }

  if (is.null(names(models))) {
    names(models) <- paste0(
      "model_", seq_along(models)
    )
  }

  valid <- vapply(models, inherits, logical(1), what = "merMod")

  if (!all(valid)) {
    stop(
      "All objects in `models` must inherit from class `merMod`.",
      call. = FALSE
    )
  }

  out <- lapply(seq_along(models), function(i) {

    mod <- models[[i]]

    # Extract convergence messages.
    conv_messages <- mod@optinfo$conv$lme4$messages

    if (is.null(conv_messages)) {
      conv_messages <- NA_character_
    } else {
      conv_messages <- paste(conv_messages, collapse = "; ")
    }

    data.frame(
      model = names(models)[i],
      n_obs = stats::nobs(mod),
      n_par = attr(stats::logLik(mod), "df"),
      logLik = as.numeric(stats::logLik(mod)),
      AIC = stats::AIC(mod),
      BIC = stats::BIC(mod),
      REML = lme4::isREML(mod),
      singular = lme4::isSingular(mod, tol = 1e-4),
      convergence = ifelse(is.na(conv_messages), "OK", "Warning"),
      message = conv_messages
    )
  })

  out <- do.call(rbind, out)
  rownames(out) <- NULL

  out
}

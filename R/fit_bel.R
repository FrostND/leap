
#' Fit a bad-enough-level model
#'
#' Fits a linear mixed-effects model predicting deterioration between
#' consecutive treatment episodes from the time elapsed between episodes,
#' the outcome score at the end of the prior episode, and the ordinal number
#' of the prior episode.
#'
#' This function is intended for transition-level data returned by
#' [episode_breaks()].
#'
#' @param data A transition-level data frame produced by
#'   [episode_breaks()].
#' @param bel Character string specifying the bad-enough-level outcome column.
#'   Defaults to `"bad_enough_level"`.
#' @param time Character string specifying the between-episode interval
#'   variable. Defaults to `"days_between"`.
#' @param prior_discharge Character string specifying the prior episode's
#'   discharge outcome column. Defaults to `"prior_discharge"`.
#' @param prior_episode Character string specifying the prior episode number
#'   column. Defaults to `"prior_episode"`.
#' @param client Character string specifying the client identifier column.
#'   Defaults to `"client_id"`.
#' @param center Logical indicating whether continuous predictors should be
#'   grand-mean centered. Defaults to `TRUE`.
#'
#' @return A fitted `lmerMod` object.
#'
#' @details
#' The fitted model is:
#'
#' \deqn{
#' \mathrm{BEL}_{ij}
#' =
#' \beta_0
#' + \beta_1(\mathrm{Time}_{ij})
#' + \beta_2(\mathrm{PriorDischarge}_{ij})
#' + \beta_3(\mathrm{PriorEpisode}_{ij})
#' + u_{0i}
#' + \varepsilon_{ij}
#' }
#'
#' where transitions are nested within clients. The random intercept accounts
#' for stable between-client differences in the tendency to deteriorate between
#' treatment episodes.
#'
#' When `center = TRUE`, the time interval and prior discharge score are
#' grand-mean centered. The prior episode number is shifted so that Episode 1
#' is coded as zero. The intercept therefore represents expected
#' between-episode deterioration following Episode 1 for a client with average
#' prior discharge and average time between episodes.
#'
#' @examples
#' \dontrun{
#' transition_data <- episode_breaks(treatment_data)
#'
#' model <- fit_bel(transition_data)
#' summary(model)
#' }
#'
#' @seealso [episode_breaks()]
#'
#' @export
fit_bel <- function(
    data,
    bel = "bad_enough_level",
    time = "days_between",
    prior_discharge = "prior_discharge",
    prior_episode = "prior_episode",
    client = "client_id",
    center = TRUE
) {

  cols_validate(data, required = c(bel, time, prior_discharge, prior_episode, client))

  df <- data

  if (center) {

    df$time_c <- df[[time]] - mean(df[[time]], na.rm = TRUE)

    df$prior_discharge_c <- df[[prior_discharge]] - mean(df[[prior_discharge]], na.rm = TRUE)

    df$prior_episode_c <- df[[prior_episode]] - 1

    model_formula <- stats::as.formula(
      paste0(bel, " ~ time_c + prior_discharge_c + prior_episode_c + ", "(1 | ", client, ")"
      )
    )

  } else {

    model_formula <- stats::as.formula(
      paste0(
        bel, " ~ ", time, " + ", prior_discharge, " + ", prior_episode," + (1 | ", client,")"
        )
    )
  }

  lme4::lmer(formula = model_formula, data = df, na.action = stats::na.omit)
}

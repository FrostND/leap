#' Estimate a candidate episode delimiter from session lags
#'
#' Estimates a candidate threshold for distinguishing routine within-episode
#' session gaps from longer gaps that may separate treatment episodes. The
#' delimiter is derived from the empirical distribution of positive
#' `session_lag` values using one of several distribution-based or
#' mixture-modeling approaches.
#'
#' @param data A data frame containing session-level treatment records. The
#'   data must contain variable `session_lag`.
#' @param method Character string specifying the method used to estimate the
#'   candidate delimiter. Must be one of `"iqr"`, `"sd"`, `"quantile"`, or
#'   `"mixture"`. Defaults to `"sd"`.
#' @param multiplier Numeric multiplier used when `method = "iqr"` or
#'   `method = "sd"`. For the IQR method, the delimiter is calculated as the
#'   third quartile plus `multiplier` times the interquartile range. For the
#'   SD method, the delimiter is calculated as the mean plus `multiplier`
#'   standard deviations. Defaults to `2`.
#' @param probability Numeric value between 0 and 1 specifying the upper
#'   quantile used when `method = "quantile"`. Defaults to `0.95`.
#'
#' @return
#' A numeric value representing the estimated candidate episode delimiter
#' in days.
#'
#' @details
#' `lag_delimiter()` operates on the empirical distribution of elapsed time
#' between consecutive sessions. Missing and non-positive session lags are
#' excluded prior to estimation. In data prepared with [add_session_lag()],
#' the first session for each client has an undefined lag and is therefore
#' excluded automatically.
#'
#' Four methods are available:
#'
#' \describe{
#'   \item{`"iqr"`}{
#'   Uses the third quartile plus a multiple of the interquartile range. This
#'   approach is relatively robust to strongly right-skewed session-lag
#'   distributions.
#'   }
#'
#'   \item{`"sd"`}{
#'   Uses the mean session lag plus a specified number of standard deviations.
#'   Because session-lag distributions are often right-skewed, this method may
#'   be influenced by unusually long gaps.
#'   }
#'
#'   \item{`"quantile"`}{
#'   Uses a specified upper quantile of the observed session-lag distribution.
#'   For example, `probability = 0.95` uses the 95th percentile.
#'   }
#'
#'   \item{`"mixture"`}{
#'   Fits a two-component Gaussian finite mixture model to log-transformed
#'   session lags using [mclust::Mclust()]. The model identifies latent
#'   short-gap and long-gap components and estimates a candidate delimiter
#'   from their classification boundary.
#'   }
#' }
#'
#' For `method = "mixture"`, session lags are transformed using `log1p()` to
#' reduce right skew and a two-component Gaussian finite mixture model is
#' fitted using [mclust::Mclust()]. The model estimates latent subpopulations
#' of relatively short and relatively long session gaps using maximum
#' likelihood via the expectation-maximization algorithm.
#'
#' Each observed lag is assigned posterior probabilities of membership in the
#' two components. The candidate delimiter is defined from the point at which
#' classification shifts from the short-gap component to the long-gap
#' component. This approach treats episode demarcation as an empirical
#' classification problem rather than imposing a fixed threshold a priori.
#'
#' The latent components should not automatically be interpreted as clinically
#' distinct treatment episodes. They represent statistically distinguishable
#' patterns in the temporal spacing of sessions and should be evaluated in
#' conjunction with substantive knowledge and sensitivity analyses.
#'
#' The resulting value should be interpreted as a data-informed candidate
#' threshold rather than a definitive clinical boundary between treatment
#' episodes. Researchers should consider the substantive meaning of the
#' delimiter and may wish to compare alternative thresholds in sensitivity
#' analyses.
#'
#' @examples
#' \dontrun{
#' # Estimate a delimiter using two standard deviations
#' lag_delimiter(data = df, method = "sd", multiplier = 1.5)
#'
#' # Estimate a delimiter using IQR method
#' lag_delimiter(data = df, method = "iqr", multiplier = 1.5)
#'
#' # Use the 95th percentile of observed session lags
#' lag_delimiter(data = df, method = "quantile", prob = 0.95)
#'
#' # Estimate a delimiter using a
#' # two-component finite mixture model
#' lag_delimiter(data = df, method = "mixture")
#'
#' # Inspect a candidate delimiter visually
#' delimiter <- lag_delimiter(data = df, method = "sd")
#'
#' plot_lag_density(data = df, delimiter = delimiter)
#' }
#'
#' @seealso
#' [add_session_lag()],
#' [plot_lag_density()],
#' [add_episode_id()],
#' [mclust::Mclust()]
#'
#' @export
lag_delimiter <- function(
    data,
    method = c("iqr", "sd", "quantile", "mixture"),
    multiplier = 2,
    prob = 0.95
) {

  method <- match.arg(method)

  # Validate required variable.
  cols_validate(data, required = "session_lag")

  # Remove undefined and non-positive session lags.
  lags <- data$session_lag[!is.na(data$session_lag) & data$session_lag > 0]

  # Estimate candidate delimiter.
  estimate_delim(
    lags,
    method = method,
    multiplier = multiplier,
    prob = prob
  )
}



#  📝   ---------------------------------------------
#  Author: Nickolas Frost, PhD
#  Updated: July 29, 2026
#
#  Description:
#  •Simulates longitudinal psychotherapy data with
#   sessions nested within treatment episodes and
#   episodes nested within clients. Script creates
#   balanced and unbalanced observation structures,
#   identifies episodes using gaps between session
#   dates, and generates outcomes under stochastic
#   and clinically meaningful episode scenarios.
#
#  Simulation scenarios vary:
#  •Episode-level random-effect variance
#  •Later-episode starting values
#  •Later-episode rates of change
#  •Later-episode treatment length

# balanced data is deterministic, 4 episodes, 10 sessions each
# unbalanced data will be probabilistic, random sampling methods.


#  📦   ---------------------------------------------
load_all()
pkgs <- c("lme4","MASS", "tidyverse","psych", "rlang", "ggthemes", "patchwork")
lapply(pkgs, library, character.only = TRUE)


#----------------------------------------
# HELPER FUNCTIONS
#----------------------------------------

# need a mapper across nested model list
map_mods <- function(x, fun, ...) {
  out <- list()

  for (i in names(x)) {
    out[[i]] <- list()

    for (j in names(x[[i]])) {
      out[[i]][[j]] <- list()

      for (k in names(x[[i]][[j]])) {
        model <- x[[i]][[j]][[k]]

        out[[i]][[j]][[k]] <- fun(model, ...)
      }
    }
  }

  out
}


# diagnose random effects
dx_re <- function(models, level_names = c("design", "cohort", "scenario")) {
  walk_models <- function(x, path = character()) {

    if (inherits(x, "merMod")) {
      var_corr <- lme4::VarCorr(x) |>
        as.data.frame() |>
        tibble::as_tibble() |>
        dplyr::transmute(
          group = grp,
          term_1 = var1,
          term_2 = var2,
          variance = vcov,
          sd = sdcor
        )

      path_names <- level_names[seq_along(path)]

      identifiers <- as.list(path)
      names(identifiers) <- path_names

      return(dplyr::bind_cols(tibble::as_tibble(identifiers),var_corr))
    }

    if (!is.list(x)) {
      stop(
        "All terminal elements must be fitted `merMod` models.",
        call. = FALSE
      )
    }

    purrr::imap_dfr(x, \(element, element_name) {
      walk_models(element, path = c(path, element_name))
    }
    )
  }
  walk_models(models)
}

# diagnose singular fits
dx_singular <- function(dx_list, design, singular = TRUE) {
  dx_list %>%
    pluck("singular") %>%
    pluck(design) %>%
    list_flatten() %>%
    as_tibble() %>%
    pivot_longer(
      cols = everything(),
      names_to = "model_id",
      values_to = "singular"
    ) %>%
    filter(singular == .env$singular)
}

# diagnose convergence
dx_converge <- function(mods) {
  out <- data.frame()
  for (design in names(mods)) {
    for (cohort in names(mods[[design]])) {
      for (scenario in names(mods[[design]][[cohort]])) {

        model <- mods[[design]][[cohort]][[scenario]]
        opt <- model@optinfo
        messages <- opt$conv$lme4$messages

        if (length(messages) == 0L) {

          message <- NA_character_

        } else {

          issues <- c(
            if (any(grepl(
              "failed to converge with max",
              messages,
              ignore.case = TRUE
            ))) {
              "failed (gradient)"
            },

            if (any(grepl(
              "degenerate Hessian",
              messages,
              ignore.case = TRUE
            ))) {
              "Degenerate Hessian"
            },

            if (any(grepl(
              "large eigenvalue",
              messages,
              ignore.case = TRUE
            ))) {
              "Large eigenvalue"
            },

            if (any(grepl(
              "nearly unidentifiable",
              messages,
              ignore.case = TRUE
            ))) {
              "Nearly unidentifiable"
            },

            if (any(grepl(
              "boundary",
              messages,
              ignore.case = TRUE
            ))) {
              "boundary (singular)"
            }
          )

          message <- if (length(issues) == 0L) {
            "Other convergence issue"
          } else {
            paste(unique(issues), collapse = "; ")
          }
        }

        out <- rbind(
          out,
          data.frame(
            design = design,
            sample = cohort,
            scenario = scenario,
            optimizer = opt$optimizer,
            convergence_code = opt$conv$opt,
            message = message,
            stringsAsFactors = FALSE
          )
        )
      }
    }
  }

  rownames(out) <- NULL
  out
}


#----------------------------------------
# 1.BUILD SESSION RECORDS
#----------------------------------------
set.seed(1234)

session_records <- function(n_clients, design = c("balanced", "unbalanced")) {
  # parameters for balanced and unbalanced
  n_episodes = 3
  eps_sessions = 12
  session_range = 5:35

  design <- match.arg(design)

  # balanced session records
  if(design == "balanced") {
    client_sessions <- n_episodes * eps_sessions

    data.frame(
      client_id = rep(paste0("client_", seq_len(n_clients)), each = client_sessions),
      session_id = rep(seq_len(client_sessions), times = n_clients),
      episode_id = rep(rep(seq_len(n_episodes), each = eps_sessions), times = n_clients),
      episode_session = rep(seq_len(eps_sessions), times = n_clients * n_episodes)
    )
  } else {

    # unbalanced sessions records
    n_sessions <- sample(session_range, size = n_clients, replace = TRUE)

    data.frame(
      client_id = rep(paste0("client_", seq_len(n_clients)), times = n_sessions),
      session_id = unlist(lapply(n_sessions, seq_len), use.names = FALSE)
    )
  }
}

dat_bal <- session_records(n_clients = 400, design = "balanced")
dat_unb <- session_records(n_clients = 400, design = "unbalanced")



#----------------------------------------
# 2.ADD SESSION DATES
#----------------------------------------

# helper
date_gaps <- function(n_sessions, start_date = "2018-01-01", gaps) {
  first_date <- as.Date(start_date) + sample(0:365, size = 1)
  first_date + c(0, cumsum(gaps))
}

# function: add dates (deterministic vs. probabilistic)
add_dates <- function(df, design = c("balanced", "unbalanced"), start_date = "2018-01-01") {

  ins_gap <- 7:30
  bet_gap <- 90:180
  gap_pr <- 0.05

  design <- match.arg(design)

  # step 1: order data frames by key variables
  if(design == "balanced") {

    df <- df[order(df$client_id, df$episode_id, df$episode_session),]

  } else {

    df <- df[order(df$client_id, df$session_id),]

  }

  # step 2: split by client
  client_ls <- split(df, df$client_id)

  # step 3: apply to function to each element of client list
  client_ls <- lapply(client_ls, function(client_data) {

    n_i <- nrow(client_data)

    if(design == "balanced") {

      is_long <- c(FALSE, diff(client_data$episode_id) != 0)[-1]

      } else {

        is_long <- sample(c(F, T), size = n_i - 1, replace = T, prob = c(1 - gap_pr, gap_pr))
    }

    gaps <- integer(n_i - 1)

    gaps[is_long] <- sample(bet_gap, size = sum(is_long), replace = TRUE)
    gaps[!is_long] <- sample(ins_gap, size = sum(!is_long), replace = TRUE)

    client_data$session_date <- date_gaps(n_sessions = n_i, start_date = start_date, gaps = gaps)
    client_data
  })

  df <- do.call(rbind, client_ls)
  rownames(df) <- NULL

  df
}

dat_bal <- add_dates(dat_bal, design = "balanced")
dat_unb <- add_dates(dat_unb, design = "unbalanced")

#----------------------------------------
# 3.ADD EPISODE VARIABLES
#----------------------------------------

# what variables are needed?
map(list(dat_bal, dat_unb), names)

dat_unb <- dat_unb %>%
  add_session_lag("client_id", "session_date") %>%
  add_episode_id("client_id", "session_lag") %>%
  add_episode_count("client_id", "episode_id") %>%
  add_episode_session("client_id", "episode_id") %>%
  add_client_episode_id("client_id", "episode_id")


dat_bal <- dat_bal %>%
  add_session_lag("client_id", "session_date") %>%
  add_episode_count("client_id", "episode_id") %>%
  add_client_episode_id("client_id", "episode_id")

# preference: order columns the same in each data
col_ids <- c(
  "client_id", "session_id",
  "session_date", "session_lag",
  "episode_id", "episode_session",
  "n_episodes", "client_episode_id"
)


dat_bal <- dat_bal[col_ids]
dat_unb <- dat_unb[col_ids]

map(list(dat_bal, dat_unb), names)

# before moving on: check later episode lengths
describe_episodes(dat_unb)
describe_episodes(dat_bal)

#.............................................................
# HACK: model convergence issue may require you to
# drop episodes with too few clients or sessions.
# drop episodes after 4 in unbalanced data to see
# if this makes any difference
#............................................................

dat_unb <- filter(dat_unb, episode_id <= 3)

#----------------------------------------
# 4.OPTIONAL: TRIM EPISODE LENGTHS
#----------------------------------------
force_trim_eps <- function(df, eps_session_shift = 0, min_sessions = 2) {

  if(eps_session_shift == 0) {

    return(df)

  }

  episodes <- split(df, df$client_episode_id)

  episodes <- lapply(episodes, function(episode_data) {

    episode_number <- unique(episode_data$episode_id)

    # Episode 1 is unchanged.
    if(episode_number == 1) {
      return(episode_data)
    }

    current_n <- nrow(episode_data)
    target_n <- max(min_sessions, current_n + eps_session_shift)

    # Shorten the episode by retaining its earliest sessions.
    if(target_n <= current_n) {
      return(episode_data[seq_len(target_n), , drop = FALSE])
    }

    # Extend the episode by copying the final row as a template.
    n_add <- target_n - current_n
    added <- episode_data[rep(current_n, n_add), , drop = FALSE]
    added$episode_session <- current_n + seq_len(n_add)
    added$session_date <- max(episode_data$session_date) + 7 * seq_len(n_add)
    added$session_lag <- 7

    rbind(episode_data, added)
  })

  df <- do.call(what = rbind, args = episodes)
  rownames(df) <- NULL
  df <- df[order(df$client_id, df$episode_id, df$episode_session), ]

  # reconstruct session numbers after trimming
  df$session_id <- ave(df$client_id, df$client_id, FUN = seq_along)
  rownames(df) <- NULL
  df
}

#----------------------------------------
# 5.STOCHASTIC VARIANCE
#----------------------------------------
stochastic <- list(

  # Client-level and episode-level variability
  # are approximately equal.
  ref = list(
    sd_client_int = 0.75,
    sd_client_slp = 0.08,
    sd_client_eps_int = 0.75,
    sd_client_eps_slp = 0.08,
    sd_residual = 0.90
  ),

  # Clients differ consistently, whereas episodes
  # within the same client are relatively similar.
  client_dominant = list(
    sd_client_int = 1.00,
    sd_client_slp = 0.10,
    sd_client_eps_int = 0.25,
    sd_client_eps_slp = 0.04,
    sd_residual = 0.90
  ),

  # Clients are relatively similar overall, whereas
  # episodes within the same client differ substantially.
  episode_dominant = list(
    sd_client_int = 0.40,
    sd_client_slp = 0.05,
    sd_client_eps_int = 1.00,
    sd_client_eps_slp = 0.14,
    sd_residual = 0.90
  )
)

#----------------------------------------
# 6.CLINICAL VARIANCE
#----------------------------------------
clinical <- list(

  # Later episodes begin at a similar level but
  # produce no further improvement.
  diminishing_resp = list(
    eps_int_shift = 0.00,
    eps_slp_shift = -0.19,
    eps_session_shift = 0
  ),

  # Later episodes begin at a lower level and
  # show slower improvement over a longer course.
  deteriorating_resp = list(
    eps_int_shift = -0.75,
    eps_slp_shift = -0.25,
    eps_session_shift = 3
  ),

  # Later episodes begin at approximately the same
  # level and show a similar rate of improvement.
  relapse_resp = list(
    eps_int_shift = 0.00,
    eps_slp_shift = 0.00,
    eps_session_shift = 0
  ),

  # Later episodes begin at a somewhat higher level,
  # improve faster, and require fewer sessions.
  efficient_resp = list(
    eps_int_shift = 0.50,
    eps_slp_shift = 0.06,
    eps_session_shift = -2
  )
)

#----------------------------------------
# 8.RANDOM EFFECTS Z
#----------------------------------------

#.............................................................
# dev note: Draw independent standard normal (z) random      :
# effects for each client and episode. These standardized    :
# effects will be multiplied by their corresponding standard :
# deviations when generating longitudinal outcomes.          :
#............................................................:

random_effects_z <- function(df) {
  clients <- unique(df$client_id)
  episodes <- unique(df$client_episode_id)

  list(
    client_int_z = setNames(rnorm(length(clients)), clients),
    client_slp_z = setNames(rnorm(length(clients)), clients),
    client_eps_int_z = setNames(rnorm(length(episodes)), episodes),
    client_eps_slp_z = setNames(rnorm(length(episodes)), episodes)
  )
}

#----------------------------------------
# 9.OUTCOME VARIABLE
#----------------------------------------
add_dv <- function(df,
    effects,
    sd_client_int,
    sd_client_slp,
    sd_client_eps_int,
    sd_client_eps_slp,
    sd_residual,
    eps_int_shift = 0,
    eps_slp_shift = 0,
    min_score = 0,
    max_score = 25,
    fixed_int = 12,
    fixed_slp = 0.18
) {

  session_c <- df$episode_session - 1  # so int. represents episode session 1
  later_eps <- df$episode_id > 1       # Indicates episodes after the first

  # Fixed effects
  fixed_int_part <- fixed_int + later_eps * eps_int_shift
  fixed_slp_part <- fixed_slp + later_eps * eps_slp_shift

  # Client-level random effects
  client_int_part <- sd_client_int * effects$client_int_z[df$client_id]
  client_slp_part <- sd_client_slp * effects$client_slp_z[df$client_id]

  # Client-by-episode random effects
  eps_int_part <- sd_client_eps_int * effects$client_eps_int_z[df$client_episode_id]
  eps_slp_part <- sd_client_eps_slp * effects$client_eps_slp_z[df$client_episode_id]

  # Combine fixed and random components
  int <- fixed_int_part + client_int_part + eps_int_part
  slp <- fixed_slp_part + client_slp_part + eps_slp_part

  # Observation-level residual error
  residual <- rnorm(n = nrow(df), mean = 0, sd = sd_residual)

  # Generate latent and bounded outcomes
  df$outcome_latent <- int + slp * session_c + residual
  df$outcome <- pmin(pmax(df$outcome_latent, min_score), max_score)

  df
}


#----------------------------------------
# 10.SIMULATE STOCHASTIC FUNCTION
#----------------------------------------
sim_stochast <- function(df, scenarios) {
  effects <- random_effects_z(df)

  out <- vector(mode = "list", length = length(scenarios))
  names(out) <- names(scenarios)

  for(i in names(scenarios)) {
    out[[i]] <- do.call(
      what = add_dv, args = c(fixed_slp = 0, list(df = df, effects = effects), scenarios[[i]]))
  }

  out
}

#----------------------------------------
# 11.SIMULATE CLINICAL FUNCTION
#----------------------------------------
sim_clinical <- function(df, params, scenarios) {

  out <- vector(mode = "list", length = length(scenarios))
  names(out) <- names(scenarios)

  for(i in names(scenarios)) {
    scenario_args <- scenarios[[i]]

    # Trim before generating the random effects and outcome.
    scenario_data <- force_trim_eps(df, eps_session_shift = scenario_args$eps_session_shift)
    outcome_args <- scenario_args[c("eps_int_shift", "eps_slp_shift")]
    effects <- random_effects_z(scenario_data)

    out[[i]] <- do.call(
      what = add_dv, args = c(list(df = scenario_data, effects = effects), params, outcome_args
    ))
  }
  out
}

#----------------------------------------
# 12.BUILD DATA LIST
#----------------------------------------
data <- list(
  balanced = list(
    stochast = sim_stochast(df = dat_bal, scenarios = stochastic),
    clinical = sim_clinical(df = dat_bal, params = stochastic$ref, scenarios = clinical)
  ),
  unbalanced = list(
    stochast = sim_stochast(df = dat_unb, scenarios = stochastic),
    clinical = sim_clinical(df = dat_unb, params = stochastic$ref, scenarios = clinical)
  )
)


rm(list = setdiff(ls(), "data"))

#----------------------------------------
# 13.PLOT EPISODE SLOPES
#----------------------------------------
.trj <- function(data, design, pattern, cohort = NULL) {
  plot_lst <- list()

  data <- pluck(data, design, pattern)
  data <- map(data, filter_cohorts, cohort)

  for(i in names(data)) {
    plot_lst[[i]] <- plot_episode_curves(data[[i]], clinical_cutoff = 12)
  }
  plot_lst
}

plots <- lst(
  unb = lst(
    full = .trj(data, "unbalanced", "clinical", cohort = "all"),
    multi = .trj(data, "unbalanced", "clinical", cohort = "multiple")),
  bal = lst(
    full = .trj(data, "balanced", "clinical", cohort = "all"),
    multi = .trj(data, "balanced", "clinical", cohort = "multiple")),
  ref = lst(
    full = .trj(data, "balanced", "stochast", cohort = "all"),
    multi = .trj(data, "balanced", "stochast", cohort = "multiple")
    )
  )


# balanced data, multiple episode attenders ONLY
pb1 = pluck(plots, "bal", "multi", "diminishing_resp")
pb2 = pluck(plots, "bal", "multi", "deteriorating_resp")
pb3 = pluck(plots, "bal", "multi", "relapse_resp")
pb4 = pluck(plots, "bal", "multi", "efficient_resp")
(pb1 | pb2 ) / (pb3 | pb4 )

# unbalanced data, multiple episode attenders ONLY
pu1 = pluck(plots, "unb", "multi", "diminishing_resp")
pu2 = pluck(plots, "unb", "multi", "deteriorating_resp")
pu3 = pluck(plots, "unb", "multi", "relapse_resp")
pu4 = pluck(plots, "unb", "multi", "efficient_resp")
(pu1 | pu2 ) / (pu3 | pu4 )

# stochastic data, multiple episode attenders ONLY
pluck(plots, "ref", "multi", "ref")
pluck(plots, "ref", "multi", "low_betw_high_within")
pluck(plots, "ref", "multi", "high_betw_low_within")


#----------------------------------------
# 14.MODEL DIAGNOSTICS
#----------------------------------------
.mod_fn <- function(data, design, pattern, cohort = c("all", "multiple")) {
  cohort <- match.arg(cohort)

  scenario_data <- pluck(data, design, pattern)

  mod_list <- vector(mode = "list", length = length(scenario_data))

  names(mod_list) <- names(scenario_data)

  for (scenario in names(scenario_data)) {
    mod_list[[scenario]] <- fit_lme(
      data = scenario_data[[scenario]], cohort = cohort, zero_center = TRUE
      )
  }
  mod_list
}

mods <- list(
  unb = list(
    full = .mod_fn(data, "unbalanced", "clinical", cohort = "all"),
    multi = .mod_fn(data, "unbalanced", "clinical", cohort = "multiple")
  ),
  bal = list(
    full = .mod_fn(data, "balanced", "clinical", cohort = "all"),
    multi = .mod_fn(data, "balanced", "clinical", cohort = "multiple")
  ),
  ref = lst(
    full = .mod_fn(data, "balanced", "stochast", cohort = "all"),
    multi = .mod_fn(data, "balanced", "stochast", cohort = "multiple")
  )
)



#.............................................................
# model fit & scale gradient issues are consistently
# only occurring for the unbalanced data models. Therefore,
# the issues are about data more than the model specs.
#.............................................................


# list functions in package
ls("package:leap")

# before saving data, remove derived episode columns
keep_cols <- function(data) {
  data <- select(data, c("client_id", "session_id", "session_date", "outcome"))
}

data <- map_depth(data, .depth = 3, keep_cols)



# clear workspace


# TODO: when satisfied with data, save objects to data/folder
# TODO: complete the rest of the function tests in tests/testthat/
# TODO: in the future, one conceptual innovation
# could be to use more sophisticated modeling
# procedures to derive appropriate gaps lengths
# to demarcate episodes. see below








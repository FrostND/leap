#---------------------------------------
# estimate_delim --> time_delimiter()
#---------------------------------------
estimate_delim <- function(x, method, multiplier, prob) {
  switch(
    method,
    sd = {
      mean(x) + multiplier * stats::sd(x)
    },
    iqr = {
      stats::quantile(x, 0.75) + multiplier * stats::IQR(x)
    },
    quantile = {
      stats::quantile(x, probs = prob, names = FALSE)
    },
    mixture = {
      (fit <- mclust::Mclust(log1p(x), G = 2, verbose = FALSE))
    }
  )
}


#--------------------------------
# filter_cohorts()
#--------------------------------
filter_cohorts <- function(data, cohort = c("all", "multiple")) {
  cohort <- match.arg(cohort)

  if (cohort == "multiple") {
    data <- subset(data, n_episodes > 1)
  }

  data
}


#--------------------------------
# select_episode()
#--------------------------------
select_episode <- function(
  data,
  method = c("first", "random"),
  client = "client_id",
  episode = "episode_id",
  seed = NULL
) {
  method <- match.arg(method)

  cols_validate(data, required = c(client, episode))

  if (method == "first") {
    return(
      subset(data, data[[episode]] == 1)
    )
  }

  if (!is.null(seed)) {
    set.seed(seed)
  }

  client_list <- split(data, data[[client]], drop = TRUE)

  out <- lapply(client_list, function(x) {
    episodes <- unique(x[[episode]])
    selected <- sample(episodes, size = 1)

    subset(x, x[[episode]] == selected)
  })

  out <- do.call(what = rbind, args = out)
  rownames(out) <- NULL

  out
}

#--------------------------------
# plot_selected()
#--------------------------------
plot_selected <- function(
  data,
  method = c("first", "random"),
  session = "episode_session",
  outcome = "outcome",
  episode = "episode_id",
  y_lims = c(0, 25),
  clinical_cutoff = NULL
) {
  method <- match.arg(method)
  cols_validate(data, required = c(episode, session, outcome))

  plot_title <- switch(
    method,
    first = "Growth trajectories using the first treatment episode",
    random = "Growth trajectories using one randomly selected treatment episode"
  )

  plot_subtitle <- switch(
    method,
    first = "One first treatment episode is retained for each client.",
    random = "One randomly selected treatment episode is retained for each client."
  )

  p <- ggplot(data, aes(x = .data[[session]], y = .data[[outcome]])) +
    geom_smooth(
      aes(group = 1, linetype = "Pooled trajectory"),
      method = "lm",
      formula = y ~ x,
      se = FALSE,
      colour = "black",
      linewidth = 1.1
    ) +
    geom_smooth(
      aes(group = .data[[episode]], linetype = "Episode-specific trajectories"),
      method = "lm",
      formula = y ~ x,
      se = FALSE,
      colour = "grey45",
      linewidth = 0.6
    ) +
    scale_linetype_manual(
      name = NULL,
      values = c(
        "Pooled trajectory" = "solid",
        "Episode-specific trajectories" = "dashed"
      )
    ) +
    scale_x_continuous(
      breaks = scales::breaks_pretty(n = 6),
      expand = expansion(mult = c(0.02, 0.02))
    ) +
    coord_cartesian(
      ylim = y_lims
    ) +
    labs(
      x = "Session within episode",
      y = "Outcome score",
      title = plot_title,
      subtitle = plot_subtitle
    ) +
    theme_bw(base_family = "Times") +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = "grey90", linewidth = 0.20),
      panel.border = element_rect(fill = NA, linewidth = 0.40),
      legend.position = "top",
      legend.key.width = grid::unit(1.4, "cm"),
      plot.title.position = "plot"
    )

  if (!is.null(clinical_cutoff)) {
    p <- p +
      geom_hline(
        yintercept = clinical_cutoff,
        colour = "grey50",
        linetype = "dotted",
        linewidth = 0.40
      )
  }

  p
}

#--------------------------------
# fit_one()
#--------------------------------
fit_one <- function(data, cohort = c("all", "multiple"), zero_center = TRUE) {
  cohort <- match.arg(cohort)

  df <- filter_cohorts(data = data, cohort = cohort)

  if (zero_center) {
    df$episode_session_c <- df$episode_session - 1
    df$episode_id_c <- df$episode_id - 1

    model_formula <- outcome ~ episode_session_c +
      episode_id_c +
      (episode_session_c | client_id)
  } else {
    model_formula <- outcome ~ episode_session +
      episode_id +
      (episode_session | client_id)
  }

  lme4::lmer(formula = model_formula, data = df)
}

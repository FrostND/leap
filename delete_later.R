

# leap:: |------------------------------------------------
load_all()

# review
ls("package:leap")

# check_raw() |-----------------------------------------------
check_raw(df_unb)

# cols_standard() |-----------------------------------------------------



# order_sessions() |------------------------------------------
order_sessions(df_unb, by = "date")

# add_variables() -------------------------------------------
tmp0 <- order_sessions(df_unb, by = "date")
tmp1 <- add_session_lag(tmp0)
tmp2 <- add_episode_id(tmp1)
tmp3 <- add_episode_session(tmp2)
tmp4 <- add_episode_count(tmp3)
tmp5 <- add_client_episode_id(tmp4)
df_unb <- add_episode_vars(df_unb)
df_bal <- add_episode_vars(df_bal)

# check_eps() ------------------------------------------------
check_eps(df_unb)


# filter_episodes()  -----------------------------------------

filter_episodes(df_unb, min_sessions = 3)
filter_responders(df_unb, low = 0.10)


# episode_breaks() -------------------------------------------
breaks <- episode_breaks(dfs$df_bal)

# plot_episode_loss() ---------------------------------------
plot_episode_loss(breaks, y_lims = c(0, 25))

# plot_lag_density() -----------------------------------------
plot_lag_density(df_unb, smooth = 3)
plot_lag_density(df_unb, smooth = 3, delimiter = 90)

# plot_episode_curves() --------------------------------------
plot_episode_curves(data = df_unb)

# plot_episode_change() --------------------------------------

# plot_cohort_change() ---------------------------------------

# plot_cohort_curves() ---------------------------------------

# lag_delimiter() --------------------------------------------
lag_std <- lag_delimiter(data = df_unb, method = "sd")
lag_iqr <- lag_delimiter(data = df_unb, method = "iqr")
lag_qnt <- lag_delimiter(data = df_unb, method = "quantile")
lag_mix <- lag_delimiter(data = df_unb, method = "mixture")



# episode_slopes() -------------------------------------------
slopes <- episode_slopes(tmp6)
plot_episode_change(slopes, y_lims = c(-10, 10))

# fit_models() -----------------------------------------------
(mod1 <- fit_sao(slopes, cohort = "multiple", model = "full"))
(mod2 <- fit_lme(dfs$df_unb, cohort = "multiple", model = "full"))
(mod3 <- fit_bel(brk))
# mod4 <- fit_brms()

# compare_lme_fit() --------------------------------------------------


# is the application of growth mixture modeling to
# delimiting treatment episodes a whole paper?

load_all()
library(tidyverse)
library(mclust)

# Print leap functions
ls("package:leap")

# pick any two data sets
df_unb <- pluck(data, "unbalanced", "clinical", "efficient_resp")
df_bal <- pluck(data, "balanced", "clinical", "efficient_resp")

# check: check_raw() ------------------------------
check_raw(df_unb)

# check: add_ functions ---------------------------
tmp0 <- order_sessions(df_unb, by = "date")
tmp1 <- add_session_lag(tmp0)
tmp2 <- add_episode_id(tmp1)
tmp3 <- add_episode_session(tmp2)
tmp4 <- add_episode_count(tmp3)
tmp5 <- add_client_episode_id(tmp4)
df_unb <- add_episode_vars(df_unb)
df_bal <- add_episode_vars(df_bal)

# check: filter_episodes()  ------------------------
filter_episodes(dfs$df_unb, min_sessions = 3)
filter_responders(dfs$df_unb, low = 0.10)

# check: episode_breaks(), and breaks plot
brk <- episode_breaks(dfs$df_bal)
plot_episode_loss(brk, y_lims = c(0, 25))

# check filter responders
filter_responders(brk, low = 0.10)

# there should be NAs in place of zeros at session 1
sum(is.na(dfs$df_unb$session_lag)) # 400

# plot lag density
plot_lag_density(dfs$df_unb, smooth = 3)
plot_lag_density(dfs$df_bal, smooth = 3)

# check lag_delimiter
lag_std <- lag_delimiter(dfs$df_unb, method = "sd")
lag_iqr <- lag_delimiter(dfs$df_unb, method = "iqr")
lag_qnt <- lag_delimiter(dfs$df_unb, method = "quantile")
lag_mix <- lag_delimiter(dfs$df_unb, method = "mixture")

# results of delimter cluster analysis
summary(lag_mix, parameters = TRUE)
plot(lag_mix, what = "density")
plot(lag_mix, what = "classification")

# episode_slopes()
slopes <- episode_slopes(tmp6)
plot_episode_change(slopes, y_lims = c(-10, 10))

# filter responders
filter_responders(slopes, type = "slope", low = 0.10)
filter_responders(slopes, type = "change_score", low = 0.10)

# try to chain operations
tmp6 %>%
  episode_slopes() %>%
  plot_episode_change(, y_lims = c(-10, 10))

# test fitting functions
(mod1 <- fit_sao(slopes, cohort = "multiple", model = "full"))
(mod2 <- fit_lme(dfs$df_unb, cohort = "multiple", model = "full"))
(mod3 <- fit_bel(brk))
# mod4 <- fit_brms()

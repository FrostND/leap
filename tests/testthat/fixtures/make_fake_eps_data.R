


eps_data <- data.frame(
  client_id = c(
    rep("A", 6),
    rep("B", 3)
  ),
  episode_id = c(
    rep(1, 3),
    rep(2, 3),
    rep(1, 3)
  ),
  episode_session = rep(1:3, 3),
  outcome = c(
    10, 11, 12,  # Client A, Episode 1: slope =  1; change =  2
    8, 10, 12,  # Client A, Episode 2: slope =  2; change =  4
    12, 11, 10   # Client B, Episode 1: slope = -1; change = -2
  ),
  n_episodes = c(
    rep(2, 6),
    rep(1, 3)
  )
)

# Objective: Evaluate NWP output and statistically postprocess the forecasts

# Load Packages
library(scoringRules)

# Data

## load data
load("C:/users/jordanar/documents/GitHub/sfss/postproc_example/data/HDwind.Rdata")

ls()

dates
str(dates)
dates[1]
dates[1] + 5
dates[1] + 100

obs
str(obs)
range(obs)

ensfc
str(ensfc)
ensfc[1,1]
ensfc[1,]
range(ensfc)

## split data
training_ind <- which(dates <= "2015-12-29")
training_ensfc <- ensfc[training_ind, ]
training_obs <- obs[training_ind]

eval_ind <- which(dates >= "2016-01-01")
eval_ensfc <- ensfc[eval_ind, ]
eval_obs <- obs[eval_ind]

## absolute verification
boxplot(training_ensfc[1:30, ], use.cols = FALSE)
points(obs[1:30], col = "red", type = "b")

matplot(training_ensfc, training_obs, col = "gray", pch = 1)
abline(a = 0, b = 1, col = "red")

ranks <- apply(training_ensfc < training_obs, 1, sum) + 1
counts <- tabulate(ranks)
barplot(counts)

# Modeling

library(scoringRules)

install.packages("scoringRules")

objective_fun <- function(par, ens_mean, obs){
  # par = (a,b,c)
  m <- cbind(1, ens_mean) %*% par[1:2]
  s <- sqrt(par[3])
  objective <- sum(crps_norm(y = obs, mean = m, sd = s))
  return(objective)
}

optim(fn = objective_fun,
      par = c(1,1,1),
      ens_mean = apply(training_ensfc, 1, mean),
      obs = training_obs)

optim_out <- optim(fn = objective_fun,
                   par = c(1,1,1),
                   ens_mean = apply(training_ensfc, 1, mean),
                   obs = training_obs)

opt_par <- optim_out$par

eval_ensmean <- apply(eval_ensfc, 1, mean)

eval_mu <- as.vector(cbind(1, eval_ensmean) %*% opt_par[1:2])
eval_sigma <- sqrt(opt_par[3])

# Evaluation

## scores
scores <- cbind(ens = crps_sample(eval_obs, dat = eval_ensfc),
                norm = crps_norm(eval_obs, mean = eval_mu, eval_sigma))
colMeans(scores)

## Calibration
rhist <- function(ensfc, obs, ...) {
  ranks <- apply(ensfc < obs, 1, sum) + 1
  counts <- tabulate(ranks)
  barplot(counts, ...)
}

eval_ppens <- eval_mu + eval_sigma * matrix(
  qnorm(1:50 / 51),
  nrow = length(eval_obs),
  ncol = 50,
  byrow = TRUE
)

par(mfrow = c(1, 2))
rhist(eval_ensfc, eval_obs, ylim = c(0, 100))
rhist(eval_ppens, eval_obs, ylim = c(0, 100))

## Sharpness
eval_sigma
mean(apply(eval_ensfc, 1, sd))

# Areas for improvement

summary(pnorm(0, mean = eval_mu, sd = eval_sigma))

max(pnorm(0, mean = eval_mu, sd = eval_sigma))

?crps.numeric

objective <- sum(crps_norm(y = obs, mean = m, sd = s))
objective <- sum(crps_tnorm(y = obs, location = m, scale = s, lower = 0, upper = Inf))

# Objective: Evaluate NWP output and statistically postprocess the forecasts

# ----  [Sebastian: Introduction to data (slides) + loading data sets into R] -----

# Load Packages
library(scoringRules)

# Data

## load data
# load("~/GitHub/sfss/postproc_example/data/HDwind.Rdata")
# load("/home/sebastian/Dropbox/ERC SummerSchool/GitHub_repo/postproc_example/data/new/HDwind.Rdata")

## contents data
ls()
dates
str(dates)
dates[1]
dates[1] + 10
dates[1] + 100
range(dates)

obs
str(obs)
range(obs)

ensfc
str(ensfc)
dim(ensfc)
range(ensfc)

# ----  [Alexander: Absolute verification of ensemble forecasts] -----

## split data
training_ind <- which(dates <= "2015-12-29")
training_ensfc <- ensfc[training_ind, ]
training_obs <- obs[training_ind]

eval_ind <- which(dates >= "2016-01-01")
eval_ensfc <- ensfc[eval_ind, ]
eval_obs <- obs[eval_ind]

## absolute verification of training data

### time-series visualization
boxplot(training_ensfc[1:30, ], use.cols = FALSE, names = dates[1:30])
points(training_obs[1:30], col = "red", type = "b")

### scatter plot
matplot(training_ensfc, training_obs, col = "gray", pch = 1)
abline(a = 0, b = 1, col = "red")

### calibration diagram
# pairs <- data.frame(fc = as.vector(training_ensfc), obs = training_obs)
# bin <- ceiling(rank(training_ensfc) / 825)
# pairs_avgs <- aggregate(pairs, by = list(bin = bin), FUN = mean)
# points(pairs_avgs[-1], pch = 16)

### rank histogram
rhist <- function(ensfc, obs, ...) {
  ranks <- apply(ensfc < obs, 1, sum) + 1
  counts <- tabulate(ranks)
  barplot(counts, names.arg = seq_along(counts), ...)
}

rhist(training_ensfc, training_obs)

# ----  [Sebastian: Implementation of simple post-processing model (slides + code)] -----

# Modeling

## (slide EMOS)

## training

### objective function
objective_fun <- function(par, ens_mean, obs){
  m <- cbind(1, ens_mean) %*% par[1:2] # mu = a + b ensmean
  s <- sqrt(par[3]) # sigma^2 = c
  objective_score <- sum(crps_norm(y = obs, mean = m, sd = s))
  return(objective_score)
}

### optimization
optim_out <- optim(par = c(1,1,1), # starting values
                   fn = objective_fun, # objective fct
                   ens_mean = apply(training_ensfc, 1, mean),
                   obs = training_obs)

optim_out

opt_par <- optim_out$par

## forecasting
### calculate out-of-sample parameters
eval_ensmean <- apply(ensfc[eval_ind,], 1, mean)

eval_mu <- as.vector(cbind(1, eval_ensmean) %*%  opt_par[1:2])
eval_sigma <- sqrt(opt_par[3])

# ----  [Alexander: Verification of post-processed forecasts] -----

# Evaluation

## absolute verification of test data

eval_ppens <- eval_mu + eval_sigma * matrix(
  qnorm(0.5:49.5 / 50),
  nrow = length(eval_mu),
  ncol = 50,
  byrow = TRUE
)

### calibration

#### scatter plot
par(mfrow = c(1, 2))
matplot(eval_ensfc, eval_obs, col = "gray", pch = 1)
abline(a = 0, b = 1, col = "red")
matplot(eval_ppens, eval_obs, col = "gray", pch = 1)
abline(a = 0, b = 1, col = "red")

#### compare rank (ensemble) and PIT (EMOS) histograms
par(mfrow = c(1, 2))
rhist(eval_ensfc, eval_obs, ylim = c(0, 100))
rhist(eval_ppens, eval_obs, ylim = c(0, 100))

PIT <- pnorm(eval_obs, eval_mu, eval_sigma)
hist(PIT)

### sharpness
boxplot(list(
  eval_ensfc_sd = apply(eval_ensfc, 1, sd),
  eval_sigma = eval_sigma
))

par(mfrow = c(1, 1))
boxplot(eval_ensfc[1:12 * 30, ], use.cols = FALSE,
        ylim = c(-1, 15), border = "blue",
        boxwex = 0.15, at = 1:12 - 0.15)
boxplot(eval_ppens[1:12 * 30, ], use.cols = FALSE,
        add = TRUE, border = "red",
        boxwex = 0.15, at = 1:12 + 0.15)
abline(h = 0, lty = 2)

## comparative evaluation of test data

### compare scores

scores <- cbind(ens = crps_sample(eval_obs, dat = eval_ensfc),
                norm = crps_norm(eval_obs, mean = eval_mu, sd = eval_sigma))
colMeans(scores)

# ----  [Alexander/Sebastian: Exercise: DIY] -----

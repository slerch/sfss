# Objective: Evaluate NWP output and statistically postprocess the forecasts

# ----  [Sebastian: Introduction to data (slides) + loading data sets into R] -----

# Data

## load data
# load("~/GitHub/sfss/postproc_example/data/HDwind.Rdata")
load("/home/sebastian/Dropbox/ERC SummerSchool/GitHub_repo/postproc_example/data/new/HDwind.Rdata")

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
training_ind <- which(dates < "2015-12-30")
training_ensfc <- ensfc[training_ind, ]
training_obs <- obs[training_ind]

eval_ind <- which(dates >= "2016-01-01")
eval_ensfc <- ensfc[eval_ind, ]
eval_obs <- obs[eval_ind]

## absolute verification of training data

### calibration diagram
pairs <- data.frame(fc = as.vector(training_ensfc), obs = training_obs)
plot(pairs, col = "gray")
abline(a = 0, b = 1, col = "red")

bin <- ceiling(rank(training_ensfc) / 825)
pairs_avgs <- aggregate(pairs, by = list(bin = bin), FUN = mean)
points(pairs_avgs[-1], pch = 16)

### rank histogram
boxplot(head(training_ensfc, 30), use.cols = FALSE)
lines(head(training_obs, 30), col = "red", type = "o")

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
library(scoringRules)

objective_fun <- function(par, ens_mean_train, obs_train){
  m <- cbind(1, ens_mean_train) %*% par[1:2] # mu = a + b ensmean
  s <- sqrt(par[3]) # sigma^2 = c
  return(sum(crps_norm(y = obs_train, location = m, scale = s))) # or mean
}

### optimization
optim_out <- optim(par = c(1,1,1), # starting values
                   fn = objective_fun, # objective fct
                   ens_mean_train = apply(training_ensfc, 1, mean),
                   obs_train = obs[training_ind])

optim_out

opt_par <- optim_out$par

## forecasting
### calculate out-of-sample parameters
eval_ind <- which(dates >= "2016-01-01")

eval_ensmean <- apply(ensfc[eval_ind,], 1, mean)

eval_mu <- as.vector(cbind(1, eval_ensmean) %*%  opt_par[1:2])
eval_sigma <- sqrt(opt_par[3])

# ----  [Alexander: Verification of post-processed forecasts] -----

# Evaluation

## absolute verification of test data

### compare rank (ensemble) and PIT (EMOS) histograms

par(mfrow = c(1, 2))
rhist(eval_ensfc, eval_obs, ylim = c(0, 100))

PIT <- pnorm(eval_obs, eval_mu, eval_sigma)
hist(PIT, ylim = c(0, 100), breaks = seq(0, 1, len = 51))

### compare scores

# ----  [Alexander/Sebastian: Exercise: DIY] -----

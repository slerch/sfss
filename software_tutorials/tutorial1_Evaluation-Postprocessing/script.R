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

ensfc
str(ensfc)

# ----  [Alexander: Absolute verification of ensemble forecasts] -----

## split data
training_ind <- which(dates < "2016-12-30")
training_ensfc <- ensfc[training_ind, ]

## absolute verification of training data

### scatter plot
plot(ensfc, rep(obs, 50))
abline(a = 0, b = 1)

boxplot(t(head(ensfc, 30)))
lines(head(obs, 30), col = "red", type = "o")

### rank histogram
rank_hist

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

ensmean_eval <- apply(ensfc[eval_ind,], 1, mean)

mu_eval <- as.vector(cbind(1, ensmean_eval) %*%  opt_par[1:2])
sig_eval <- sqrt(opt_par[3])

# ----  [Alexander: Verification of post-processed forecasts] -----

# Evaluation

## absolute verification of test data

### compare rank (ensemble) and PIT (EMOS) histograms

### compare scores

# ----  [Alexander/Sebastian: Exercise: DIY] -----

#
# do it yourself, mix it up, change things
#

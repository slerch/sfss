rm(list=ls())

data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/"
load(paste0(data_dir, "HDwind.Rdata"))

library(scoringRules)

crpsv <- crps_sample(y = observation, dat = ensfc)
summary(crpsv)
plot(date, crpsv, type = "l")

# 60h ahead forecasts
# initialized at day 1 00 UTC
# valid at day 3, 12 UTC
# therefore, to post-process forecasts initialized at day 4, 
#   past pairs from day 1 (and before), but not from day 2,3

## excercise: fit a post-processing model for 2016

## simple benchmark model:
#     TN EMOS model, mean = linear function of ens mean, sd = constant

objective_fun_minCRPS <- function(par, ens_mean_train, obs_train){
  m <- cbind(1, ens_mean_train) %*% par[1:2]
  s <- sqrt(par[3])
  return(sum(crps_tnorm(y = obs_train, location = m, scale = s, 
                        lower = 0, upper = Inf)))
}

# for 2016-01-01, we can use past pairs up to 2015-12-29
ind_training <- which(date <= "2015-12-29")
ensfc_mean_training <- apply(ensfc[ind_training,], 1, mean)
obs_training <- observation[ind_training]

optim_out <- optim(par = c(1,1,1), fn = objective_fun_minCRPS, 
                   ens_mean_train = ensfc_mean_training, 
                   obs_train = obs_training)

opt_par <- optim_out$par

# comute out of sample parameters for 2016
ind_2016 <- which(date >= "2016-01-01")
ens_mean_2016 <- apply(ensfc[ind_2016,], 1, mean)

tn_loc <- c(cbind(1, ens_mean_2016) %*% opt_par[1:2])
tn_sc <- sqrt(opt_par[3])

crps_emos <- crps_tnorm(y = observation[ind_2016], location = tn_loc, scale = tn_sc, 
                        lower = 0, upper = Inf)
crps_ens <- crps_sample(y = observation[ind_2016], dat = ensfc[ind_2016,])

summary(crps_emos)
summary(crps_ens)

summary(crps_ens - crps_emos)
hist(crps_ens - crps_emos)
plot(date[ind_2016], crps_ens - crps_emos, type = "l")
abline(h = 0, lty = 2)

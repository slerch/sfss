rm(list=ls())

data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/new/"
load(paste0(data_dir, "HDwind.Rdata"))

library(scoringRules)

crpsv <- crps_sample(y = obs, dat = ensfc)
summary(crpsv)
plot(dates, crpsv, type = "l")

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
ind_training <- which(dates <= "2015-12-29")
ensfc_mean_training <- apply(ensfc[ind_training,], 1, mean)
obs_training <- obs[ind_training]

optim_out <- optim(par = c(1,1,1), fn = objective_fun_minCRPS, 
                   ens_mean_train = ensfc_mean_training, 
                   obs_train = obs_training)
# for 2016-01-01, we can use past pairs up to 2015-12-29
ind_training <- which(date <= "2015-12-29")
ensfc_mean_training <- apply(ensfc[ind_training,], 1, mean)
obs_training <- observation[ind_training]

optim_out <- optim(par = c(1,1,1), fn = objective_fun_minCRPS, 
                   ens_mean_train = ensfc_mean_training, 
                   obs_train = obs_training)
optim_out

opt_par <- optim_out$par

# comute out of sample parameters for 2016
ind_2016 <- which(dates >= "2016-01-01")
ens_mean_2016 <- apply(ensfc[ind_2016,], 1, mean)

tn_loc <- c(cbind(1, ens_mean_2016) %*% opt_par[1:2])
tn_sc <- sqrt(opt_par[3])

crps_emos <- crps_tnorm(y = obs[ind_2016], location = tn_loc, scale = tn_sc, 
                        lower = 0, upper = Inf)
crps_ens <- crps_sample(y = obs[ind_2016], dat = ensfc[ind_2016,])

summary(crps_emos)
summary(crps_ens)

summary(crps_ens - crps_emos)
hist(crps_ens - crps_emos)
plot(dates[ind_2016], crps_ens - crps_emos, type = "l")
abline(h = 0, lty = 2)


# exercise: Try to improve simple benchmark model
# - what other information from ensemble can be user?
# - are there other possible parametric families to use?
# - is there a better way to select the training period?

## first test to improve simple benchmark model
objective_fun_minCRPS2 <- function(par, ens_mean_train, ens_sd_train, obs_train){
  m <- cbind(1, ens_mean_train) %*% par[1:2]
  s_tmp <- cbind(1, ens_sd_train) %*% par[3:4]
  if(any(s_tmp < 0)){
    return(999999)
  } else{
    s <- sqrt(s_tmp)
    return(sum(crps_tnorm(y = obs_train, location = m, scale = s, 
                          lower = 0, upper = Inf)))
  }
}

# for 2016-01-01, we can use past pairs up to 2015-12-29
ind_training <- which(dates <= "2015-12-29")
ensfc_mean_training <- apply(ensfc[ind_training,], 1, mean)
obs_training <- obs[ind_training]
ensfc_sd_training <- apply(ensfc[ind_training,], 1, sd)

optim_out2 <- optim(par = c(1,1,1,1), fn = objective_fun_minCRPS2, 
                    ens_mean_train = ensfc_mean_training, 
                    ens_sd_train = ensfc_sd_training,
                    obs_train = obs_training, method = "BFGS")

ind_2016 <- which(dates >= "2016-01-01")
ens_mean_2016 <- apply(ensfc[ind_2016,], 1, mean)
ens_sd_2016 <- apply(ensfc[ind_2016,], 1, sd)

tn_loc2 <- c(cbind(1, ens_mean_2016) %*% optim_out2$par[1:2])
tn_sc2_temp <- c(cbind(1, ens_sd_2016) %*% optim_out2$par[3:4])
tn_sc2 <- sqrt(tn_sc2_temp)

crps_emos2 <- crps_tnorm(y = obs[ind_2016], location = tn_loc2, scale = tn_sc2, 
                         lower = 0, upper = Inf)

summary(crps_emos2)
summary(crps_emos)

summary(crps_emos - crps_emos2) ## slightly better
## some tests for extracted forecast and analysis data

rm(list=ls())

data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/"

load(paste0(data_dir, "HDwind_analysis.Rdata"))
load(paste0(data_dir, "HDwind_ensfc.Rdata"))

# compare dates
any(as.Date(as.character(dates), format = "%Y%m%d") != fcdates)

df <- data.frame(cbind(observation, ensfc), row.names = fcdates)
names(df) <- c("obs", sprintf("fc.%d", 1:50))

# some forecast evaluation

ensfc_mean <- apply(df[,2:51], 1, mean)
fcerr <- df$obs - ensfc_mean

plot(fcerr, type = "l")
summary(fcerr)

ae <- abs(fcerr)
plot(ae, type = "l")
summary(ae)

library(scoringRules)
crps_ens <- crps_sample(y = as.numeric(df$obs), 
                        dat = apply(df[,grep('^fc', names(df))], 2, as.numeric))

summary(crps_ens)
mean(crps_ens)
plot(crps_ens, type = "l")

## interpolated 

rm(list=ls())

data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/"

load(paste0(data_dir, "HDwind_analysis_interpolated.Rdata"))
load(paste0(data_dir, "HDwind_ensfc_interpolated.Rdata"))

# compare dates
any(as.Date(as.character(dates), format = "%Y%m%d") != fcdates)

df <- data.frame(cbind(observation, ensfc), row.names = fcdates)
names(df) <- c("obs", sprintf("fc.%d", 1:50))

# some forecast evaluation

ensfc_mean <- apply(df[,2:51], 1, mean)
fcerr <- df$obs - ensfc_mean

plot(fcerr, type = "l")
summary(fcerr)

ae <- abs(fcerr)
plot(ae, type = "l")
summary(ae)

library(scoringRules)
crps_ens <- crps_sample(y = as.numeric(df$obs), 
                        dat = apply(df[,grep('^fc', names(df))], 2, as.numeric))

summary(crps_ens)
mean(crps_ens)
plot(crps_ens, type = "l")

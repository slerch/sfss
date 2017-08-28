rm(list=ls())

data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/new/"
load(paste0(data_dir, "ensfc_processed_2015.Rdata"))
load(paste0(data_dir, "ensfc_processed_2016.Rdata"))
load(paste0(data_dir, "analysis_processed.Rdata"))

# check forecast valid dates and observation dates
dates_fc <- c(dates2015, dates2016)
any(dates_fc != dates_obs)
dates <- dates_obs

ensfc <- rbind(ensfc2015, ensfc2016)

# check dimensions
dim(ensfc)
length(obs)

# save combined forecast and observation data
save(ensfc, obs, dates, 
     file = paste0(data_dir, "HDwind.Rdata"))
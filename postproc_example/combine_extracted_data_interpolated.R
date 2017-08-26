rm(list=ls())

data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/"

load(paste0(data_dir, "HDwind_analysis_interpolated.Rdata"))
load(paste0(data_dir, "HDwind_ensfc_interpolated.Rdata"))

ls()
any(as.Date(as.character(dates), format = "%Y%m%d") != fcdates)

date <- as.Date(as.character(dates), format = "%Y%m%d")        

save(date, ensfc, observation, file = paste0(data_dir, "HDwind.Rdata"))

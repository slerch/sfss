rm(list=ls())

## extract forecasts at a grid point close to Heidelberg 
## see data_preprocessing/data_retrieval_fc.py for details on data retrieval

# ncdf4 R package can be used to load data
library(ncdf4)
data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/new/"
data_nc <- nc_open(paste0(data_dir,"ecmwf_ensfc_raw_2015.nc"))

# extract variables with ncvar_get
uwind <- ncvar_get(nc = data_nc, varid = "u10")
vwind <- ncvar_get(nc = data_nc, varid = "v10")

# identify content and dimension interpretation for uwind, vwind
dim(uwind)
dim_meanings <- c(data_nc$var$u10$dim[[1]]$name,
                  data_nc$var$u10$dim[[2]]$name,
                  data_nc$var$u10$dim[[3]]$name,
                  data_nc$var$u10$dim[[4]]$name)
dim_meanings

memberid <- ncvar_get(nc = data_nc, varid = "number")

time <- ncvar_get(nc = data_nc, varid = "time")
# strange time format:
ncatt_get(nc = data_nc, varid = "time") # "hours since 1900-01-01 00:00:0.0"
# convert to standard format matching observations
time_converted <- as.POSIXlt(time*3600, tz = "UTC", origin = "1900-01-01 00:00")
dates <- as.Date(time_converted)

lats <- ncvar_get(nc = data_nc, varid = "latitude")
lons <- ncvar_get(nc = data_nc, varid = "longitude")

# position indicators for "Heidelberg"
posHD_lat <- which(lats == 49.5)
posHD_lon <- which(lons == 8.5)

# extract relevant entries of u and v wind components 
uwind_fc <- t(uwind[posHD_lon, posHD_lat,,])
vwind_fc <- t(vwind[posHD_lon, posHD_lat,,])

ensfc2015 <- sqrt(uwind_fc^2 + vwind_fc^2)
dates2015 <- dates

save(ensfc2015, dates2015, file = paste0(data_dir, "ensfc_processed_2015.Rdata"))

nc_close(data_nc)

## ----------------------- ##

## repeat for 2016
rm(list=ls())

library(ncdf4)
data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/new/"
data_nc <- nc_open(paste0(data_dir,"ecmwf_ensfc_raw_2016.nc"))

# extract variables with ncvar_get
uwind <- ncvar_get(nc = data_nc, varid = "u10")
vwind <- ncvar_get(nc = data_nc, varid = "v10")

time <- ncvar_get(nc = data_nc, varid = "time")
# strange time format:
ncatt_get(nc = data_nc, varid = "time") # "hours since 1900-01-01 00:00:0.0"
# convert to standard format matching observations
time_converted <- as.POSIXlt(time*3600, tz = "UTC", origin = "1900-01-01 00:00")
dates <- as.Date(time_converted)

lats <- ncvar_get(nc = data_nc, varid = "latitude")
lons <- ncvar_get(nc = data_nc, varid = "longitude")

# position indicators for "Heidelberg"
posHD_lat <- which(lats == 49.5)
posHD_lon <- which(lons == 8.5)

# extract relevant entries of u and v wind components 
uwind_fc <- t(uwind[posHD_lon, posHD_lat,,])
vwind_fc <- t(vwind[posHD_lon, posHD_lat,,])

ensfc2016 <- sqrt(uwind_fc^2 + vwind_fc^2)
dates2016 <- dates

save(ensfc2016, dates2016, file = paste0(data_dir, "ensfc_processed_2016.Rdata"))

nc_close(data_nc)
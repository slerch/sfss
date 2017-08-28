rm(list=ls())

## extract ERA-interim analysis data at a grid point close to Heidelberg 
## see data_preprocessing/data_retrieval_analysis.py for details on data retrieval

# ncdf4 R package can be used to load data
library(ncdf4)
data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/new/"
data_nc <- nc_open(paste0(data_dir,"analysis_raw.nc"))

# extract variables with ncvar_get
uwind <- ncvar_get(nc = data_nc, varid = "u10")
vwind <- ncvar_get(nc = data_nc, varid = "v10")

# identify content and dimension interpretation for uwind, vwind
dim(uwind)
dim_meanings <- c(data_nc$var$u10$dim[[1]]$name,
                  data_nc$var$u10$dim[[2]]$name,
                  data_nc$var$u10$dim[[3]]$name)
dim_meanings

time <- ncvar_get(nc = data_nc, varid = "time")
# strange time format:
ncatt_get(nc = data_nc, varid = "time") # "hours since 1900-01-01 00:00:0.0"
# convert to standard format matching observations
time_converted <- as.POSIXlt(time*3600, tz = "UTC", origin = "1900-01-01 00:00")
dates_obs <- as.Date(time_converted)

lats <- ncvar_get(nc = data_nc, varid = "latitude")
lons <- ncvar_get(nc = data_nc, varid = "longitude")

# position indicators for "Heidelberg"
posHD_lat <- which(lats == 49.5)
posHD_lon <- which(lons == 8.5)

# extract relevant entries of u and v wind components 
uwind_obs <- uwind[posHD_lon, posHD_lat,]
vwind_obs <- vwind[posHD_lon, posHD_lat,]

obs <- sqrt(uwind_obs^2 + vwind_obs^2)

save(obs, dates_obs, file = paste0(data_dir, "analysis_processed.Rdata"))

nc_close(data_nc)
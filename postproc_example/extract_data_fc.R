rm(list=ls())

## load and process grib files with ensemble forecasts,
## extract grid point close to Heidelberg, and save as Rdata file

## grib file retrieved from http://apps.ecmwf.int/datasets/data/interim-full-daily/
## web API request details:

## file 1:
# Origin: ECMWF
# Area: 50.0°N 7.0°E 48.0°N 9.0°E
# Type: Perturbed forecast
# Number: 1 to 50
# Step: 60
# Version: prod
# Type of level: Surface
# Time: 00:00:00
# Date: 20141230 to 20151229
# Grid: 1.0° x 1.0°
# Parameter: 165, 166
# Class: TIGGE

## file 2:
# Origin: ECMWF
# Area: 50.0°N 7.0°E 48.0°N 9.0°E
# Type: Perturbed forecast
# Number: 1 to 50
# Step: 60
# Version: prod
# Type of level: Surface
# Time: 00:00:00
# Date: 20151230 to 20161229
# Grid: 1.0° x 1.0°
# Parameter: 165, 166
# Class: TIGGE

## loading the downloaded grib files turned out to be problematic
## since R crashed due to a lack of memory 
## Therefore: convert data into netCDF data:
## requires installation of ecCodes library
## in Terminal:
# grib_to_netcdf ensfc2015.grib -o ensfc2015.nc
# grib_to_netcdf ensfc2015.grib -o ensfc2015.nc

## output should look something like this
# grib_to_netcdf: Version 2.4.1
# grib_to_netcdf: Processing input file 'ensfc2015.grib'.
# grib_to_netcdf: Found 36500 GRIB fields in 1 file.
# grib_to_netcdf: Ignoring key(s): method, type, stream, refdate, hdate
# grib_to_netcdf: Creating netCDF file 'ensfc2015.nc'
# grib_to_netcdf: NetCDF library version: 4.1.3 of Feb 24 2014 21:05:37 $
#   grib_to_netcdf: Creating large (64 bit) file format.
# grib_to_netcdf: Defining variable 'u10'.
# grib_to_netcdf: Defining variable 'v10'.
# grib_to_netcdf: Done.

# ncdf4 R package can be used to load data
library(ncdf4)
data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/"
data_nc <- nc_open(paste0(data_dir,"ensfc2015.nc"))

# view some information on data_nc
str(data_nc)

data_nc$dim$latitude

str(data_nc$dim$number)
data_nc$dim$number$vals

str(data_nc$var$u10$dim)
str(data_nc$var$u10)

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
posHD_lat <- which(lats == 49)
posHD_lon <- which(lons == 8)

# extract relevant entries of u and v wind components 
uwind_fc <- t(uwind[posHD_lon, posHD_lat,,])
vwind_fc <- t(vwind[posHD_lon, posHD_lat,,])

ensfc2015 <- sqrt(uwind_fc^2 + vwind_fc^2)
dates2015 <- dates

save(ensfc2015, dates2015, file = paste0(data_dir, "ensfc2015.Rdata"))

nc_close(data_nc)

## repeat for 2016
rm(list=ls())

library(ncdf4)
data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/"
data_nc <- nc_open(paste0(data_dir,"ensfc2016.nc"))

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

time <- ncvar_get(nc = data_nc, varid = "time")
# strange time format:
ncatt_get(nc = data_nc, varid = "time") # "hours since 1900-01-01 00:00:0.0"
# convert to standard format matching observations
time_converted <- as.POSIXlt(time*3600, tz = "UTC", origin = "1900-01-01 00:00")
dates <- as.Date(time_converted)

lats <- ncvar_get(nc = data_nc, varid = "latitude")
lons <- ncvar_get(nc = data_nc, varid = "longitude")

# position indicators for "Heidelberg"
posHD_lat <- which(lats == 49)
posHD_lon <- which(lons == 8)

# extract relevant entries of u and v wind components 
uwind_fc <- t(uwind[posHD_lon, posHD_lat,,])
vwind_fc <- t(vwind[posHD_lon, posHD_lat,,])

ensfc2016 <- sqrt(uwind_fc^2 + vwind_fc^2)
dates2016 <- dates

save(ensfc2016, dates2016, file = paste0(data_dir, "ensfc2016.Rdata"))

nc_close(data_nc)

## combine
rm(list=ls())

data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/postproc_example/data/"
load(paste0(data_dir, "ensfc2015.Rdata"))
load(paste0(data_dir, "ensfc2016.Rdata"))

fcdates <- c(dates2015, dates2016)
ensfc <- rbind(ensfc2015, ensfc2016)

save(fcdates, ensfc, file = paste0(data_dir, "HDwind_ensfc.Rdata"))
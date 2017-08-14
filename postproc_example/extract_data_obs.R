rm(list=ls())

## grib file retrieved from http://apps.ecmwf.int/datasets/data/interim-full-daily/
## request details:
# Stream: Atmospheric model
# Area: 50.0°N 5.0°E 45.0°N 10.0°E
# Type: Analysis
# Dataset: interim_daily
# Step: 0
# Version: 1
# Type of level: Surface
# Time: 12:00:00
# Date: 20150101 to 20161231
# Grid: 1.0° x 1.0°
# Parameter: 10 metre U wind component, 10 metre V wind component
# Class: ERA Interim

# to load grib file, install gribr package from https://github.com/nawendt/gribr
# requires installation of ecCodes library
library(gribr)

data_dir <- "/home/sebastian/Dropbox/ERC SummerSchool/software_tutorials/code/data/"

g <- grib_open(paste0(data_dir,"analysis.grib"))

gl <- grib_list(g)
gl_shortnames <- gl$shortName

indgl_u <- which(gl$shortName == "10u")
indgl_v <- which(gl$shortName == "10v")

gm <- grib_get_message(g, 1:nrow(gl))
latlon <- grib_latlons(gm[[1]])
# position of "Heidelberg": closest grid point = 49N 8E
pos_HD <- which(latlon$lats == 49 & latlon$lons == 8)

udates <- NULL
vdates <- NULL
uval <- NULL
vval <- NULL

nmsg <- nrow(gl)

for(mm in 1:nmsg){
  
  if(mm %% 10 == 0){print(mm)}
  
  thismsg <- gm[[mm]]
  
  if(is.element(mm, indgl_u)){
    udates[mm] <- thismsg$dataDate
    gmval <- thismsg$values
    uval[mm] <- gmval[pos_HD]
  }
  
  if(is.element(mm, indgl_v)){
    vdates[mm] <- thismsg$dataDate
    gmval <- thismsg$values
    vval[mm] <- gmval[pos_HD]
  }
}

grib_close(g)

udates <- udates[indgl_u]
vdates <- vdates[indgl_v]
uval <- uval[indgl_u]
vval <- vval[indgl_v]

any(udates != vdates)
dates <- udates

# compute wind speed from u and v components
observation <- sqrt(uval^2 + vval^2)
hist(observation)
plot(observation, type = "l")
summary(observation)

save(dates, observation, file = paste0(data_dir,"HDwind_analysis.Rdata"))
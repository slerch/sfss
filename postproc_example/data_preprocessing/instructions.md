These are instructions to retrieve and process the data sets that were used to generated the data used in the software tutorial. All data is available publicly from the TIGGE and ERA-interim archives at ECMWF (requires registration, see http://apps.ecmwf.int/datasets/)

Note: The following has only been tested under Linux.

## prerequisites
- installation of Python and R
- installation of ecCodes library (https://software.ecmwf.int/wiki/display/ECC/ecCodes+Home)
- installation of ECMWF API to access public data sets (https://software.ecmwf.int/wiki/display/WEBAPI/Access+ECMWF+Public+Datasets), including registration of a user account
- installation of the 'ncdf4' package for R, and possibly additional packages and libraries for netCDF support

## download ECMWF forecast data
- run data_preprocessing/data_retrieval_fc.py (set 'target' to an appropriate path; requires ECMWF API; each file is around 7.5 MB)
- convert grib data to netCDF for better handling in Python and R:
    - navigate to folder with downloaded grib files 
    - run `grib_to_netcdf -o ecmwf_ensfc_raw_2015.nc ecmwf_ensfc_raw_2015.grib` and `grib_to_netcdf -o ecmwf_ensfc_raw_2016.nc ecmwf_ensfc_raw_2016.grib` (requires ecCodes)
    - grib files are no longer required and can be deleted
    
## download ERA-interim analysis data
- run data_preprocessing/data_retrieval_analysis.py (set 'target' to an appropriate path; requires ECMWF API)

## extract forecast and observation data
- copy all *.nc files to a single folder
- run data_preprocessing/extract_data_fc.R to extract forecast data and save as .Rdata files 
- run data_preprocessing/extract_data_analysis.R to extract analysis data and save as .Rdata file 
- *.nc files are no longer required and can be deleted

## match and combine forecast and observation data
- run data_preprocessing/combine_data.R to create a single .Rdata file with all forecasts and observations (300 KB)
- all files other than HDwind.Rdata are no longer required and can be deleted
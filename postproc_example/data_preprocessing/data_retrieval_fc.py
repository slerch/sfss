# -*- coding: utf-8 -*-
"""
Created on Mon Aug 28 16:45:03 2017

@author: sebastian
"""


## retrieve ECMWF forecast data, based on example from
## https://software.ecmwf.int/wiki/display/WEBAPI/TIGGE+retrieval+efficiency

# ECMWF forecasts from TIGGE data set: 
#   u- and v-wind fields 
#   forecasts valid at 12 UTC, for years 2015 and 2016
#   init time 00 UTC
#   60 h ahead forecasts
#   0.5° resolution
#   small area around Heidelberg
    
#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
    
def retrieve_tigge_data():
    for date in dates:
        target = data_dir + "ecmwf_ensfc_raw_" + date[14:18] + ".grib"
        tigge_request(date, target)
          
def tigge_request(date, target):
    '''
       A TIGGE request for ECMWF perturbed forecasts.
    '''
    server.retrieve({
        'origin'    : "ecmf",
        'levtype'   : "sfc",
        'number'    : mem_numbers,
        'expver'    : "prod",
        'dataset'   : "tigge",
        'step'      : "60",
        'grid'      : "0.5/0.5",
        'param'     : "165/166",
        'area'      : "50/8/49/9",
        'time'      : "00",
        'date'      : date,
        'type'      : "pf",
        'class'     : "ti",
        'target'    : target,
    })
 
if __name__ == '__main__':
    mem_numbers = ''.join([''.join([str(i) + "/" for i in xrange(1,50)]),'50']) 
    dates = ["2014-12-30/to/2015-12-29", "2015-12-30/to/2016-12-29"]
    data_dir = "/home/sebastian/"     
    retrieve_tigge_data()
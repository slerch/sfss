# -*- coding: utf-8 -*-
"""
Created on Mon Aug 28 16:54:48 2017

@author: sebastian
"""

#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
    
server = ECMWFDataServer()
    
server.retrieve({
    'stream'    : "oper",
    'levtype'   : "sfc",
    'param'     : "165.128/166.128",
    'dataset'   : "interim",
    'step'      : "0",
    'grid'      : "0.5/0.5",
    'time'      : "12",
    'date'      : "2015-01-01/to/2016-12-31",
    'type'      : "an",
    'class'     : "ei",
    'area'      : "50/8/49/9",
    'format'    : "netcdf",
    'target'    : "/home/sebastian/analysis_raw.nc"
 })
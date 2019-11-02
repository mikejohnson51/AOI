# AOI: Areas of Interest <img src="man/figures/logo.png" width=130 height = 150 align="right" />

[![Build Status][image-1]][1] 
[![Coverage Status](https://img.shields.io/coveralls/mikejohnson51/AOI.svg)](https://coveralls.io/r/mikejohnson51/AOI?branch=master)
[![DOI][image-3]][3]


**Welcome to the AOI R homepage!** <br>

If you've ever found yourself needing to deal with spatial boundaries in R this package should be able to help. The purpose is to help users reproducibly create programmatic  boundaries to use in analysis and mapping workflows. The package targets five main use cases:

1. Perform basic forward and reverse geocoding tasks
2. Create flexible "Areas of Interest" based on fiat boundaries, place names, and locations. 
3. Offer a back end to interface with large web-based datasets 
4. Facilitate iterative analysis in an era of big geospatial data
5. Enhance reproducible in spatial analysis.

The package also includes functions to faciliate basic tasks in AOI work flows such as unioning, buffering, converting between string and spatial representations, and 

This package builds on the sf package and in cases of overlap, only offers wrappers of common workflows. By their nature these wrappers save users lines of code and repetition but are less flexible then there base sf functions. 

### Installation:

	install.packages("devtools")
	devtools::install_github("mikejohnson51/AOI")

Current packages/applications using AOI:

1. [HydroData][9]
2. [NWM][10]
3. [FlowFinder][11]
4. [climateR][18]
5. [FloodMapper][19]

### Support:

The "AOI" R package is written by [Mike Johnson][12], a graduate student at the [University of California, Santa Barbara][13] in [Keith C. Clarke's][14] Lab, 2018. <br><br>
Development is supported with funds from the [UCAR COMET program][15]; the [NOAA National Water Center][16]; and the University of California, Santa Barbara and is available under the [MIT license][17]

[1]:	https://travis-ci.org/mikejohnson51/AOI
[2]:	https://coveralls.io/github/mikejohnson51/AOI?branch=master
[3]:	https://zenodo.org/badge/latestdoi/139353238
[4]:	./articles/clipAreas.html
[5]:	./articles/stateCounty.html
[6]:	./articles/clipAreas.html
[7]:	./articles/tools.html
[8]:	./articles/useCases.html
[9]:	https://github.com/mikejohnson51/HydroData
[10]:	https://github.com/mikejohnson51/NWM
[11]:	https://github.com/mikejohnson51/FlowFinder
[12]:	https://mikejohnson51.github.io
[13]:	https://geog.ucsb.edu
[14]:	http://www.geog.ucsb.edu/~kclarke/
[15]:	http://www.comet.ucar.edu
[16]:	http://water.noaa.gov
[17]:	https://opensource.org/licenses/MIT
[18]:   https://github.com/mikejohnson51/climateR
[19]:   https://github.com/mikejohnson51/LivingFlood

[image-1]:	https://travis-ci.org/mikejohnson51/AOI.svg?branch=master
[image-2]:	https://img.shields.io/coveralls/github/mikejohnson51/AOI.svg
[image-3]:	https://zenodo.org/badge/139353238.svg

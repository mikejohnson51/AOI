# AOI: Areas of Interest <img src="man/figures/logo.png" width=130 height = 150 align="right" />

[![Build Status][image-1]][1] 
[![Coveralls github][image-2]][2]
[![DOI][image-3]][3]


**Welcome to the AOI R homepage!** <br>

If you've ever found yourself needing to geocode or reverse-geocode a location, formalize an area of interest, get bounding geometries, describe a place by lat/long, or better understand spatial locations, this package should be able to help. 

An area of interest (AOI) is a geographic extent. It helps confine and formalize a unit of work to a geographic area, and prioritize and define research and sub setting efforts while improving reproducibility. They are built around concrete spatial attributes but often are discussed in a more colloquial way. The aim of the is package is to help make the colloquial understanding of space more concrete in the R environment.

`AOI` lets users define regions through a common query to achieve spatial geometries that can be used in sub setting, clipping, and mapping operations. Tools are provided to help define, describe, and convert points, boundaries, and features to usable forms including strings. In principle, the AOI package helps accomplish five main tasks increasing in order of simply providing convenience to providing new functionality to the deep R spatial ecosystem. These include helping:

1. Create bounding geometries of existing `sp`, `sf`, and `raster` objects (see [here][4])
2. Get `sp`, or `sf`, state and county geometries and/or their bounding geometries (see [here][5])
3. Provide geocoding and reverse geocoding functionalities from OSM and ESRI
4. Create `sp` or `sf` geometries from a given location and bounding box dimensions. (see [here][6])
5. Map, describe and communicate AOIs to others. (see [here][7])

All functions are designed to be used with the magrittr pipe operation `%>%` so that they can be easily integrated with other spatial packages in the R ecosystem (see [here][8])

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

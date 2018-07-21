## AOI <img src="https://github.com/mikejohnson51/AOI/blob/master/docs/logo.png" width=40 align="left" />

<br>

[![Build Status](https://travis-ci.org/mikejohnson51/AOI.svg?branch=master)](https://travis-ci.org/mikejohnson51/AOI) 
[![Coveralls github](https://img.shields.io/coveralls/github/mikejohnson51/AOI.svg)](https://coveralls.io/github/mikejohnson51/AOI?branch=master) [![DOI](https://zenodo.org/badge/139353238.svg)](https://zenodo.org/badge/latestdoi/139353238)


An area of interest (AOI) is the geographic extent of a project. It helps confine the unit of work to a geographic area, and helps to not only prioritize and define research and subsetting efforts, but to improve reproducibility across studies. This package aims to make finding state, county and geographic AOIs easier, through a common query system based on 'state', 'county' and 'clip' parameters. AOIs for all queries are returned as a `sp::SpatialPolygon`. It is intended to backend spatial subsetting packages/tasks; serve front end applications; or stand alone. Find a documented see of example @ https://mikejohnson51.github.io/AOI/

## Returned Objects

All returned objects from AOI functions are ``sp::SpatialPolygons`` projected to ```+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0+no_defs')``` / ```EPSG:4269```

### Examples:

See a documented set of examples [here](https://mikejohnson51.github.io/AOI/)

Packages and services currently requiring a spatial AOI include (but are not limited to):

[HydroData^](http://mikejohnson51.github.io/HydroData/) <br>
[nwm^](https://github.com/mikejohnson51/NWM)<br>
[FlowlineFinder^](https://github.com/mikejohnson51/FlowlineFinder)<br>
[FedData](https://cran.r-project.org/web/packages/FedData/index.html)<br>
[nhdplusTools](https://github.com/dblodgett-usgs/nhdplusTools)<br>

 ^using the AOI package

### Installation:

```
install.packages("devtools")
devtools::install_github("mikejohnson51/AOI")
```
### Support:

Package development is supported with funds from the UCAR COMET program; the NOAA National Water Center; and the University of California, Santa Barbara

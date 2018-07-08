## AOI

[![Build Status](https://travis-ci.org/mikejohnson51/AOI.svg?branch=master)](https://travis-ci.org/mikejohnson51/AOI) 
[![Coveralls github](https://img.shields.io/coveralls/github/mikejohnson51/AOI.svg)](https://coveralls.io/github/mikejohnson51/AOI?branch=master)

An area of interest (AOI) is the geographic extent of a project. It helps confine the unit of work to a geographic area, and helps to not only proritize and define research and subsetting efforts, but to improve reproducabilty across studies. This package aims to make finding state, county and geographic AOIs easier, through a common query system based on 'state', 'county' and 'clip' parameters. AOIs for all queryies are retruned as ```\code{SpatialPolygons}```.  It is intended to backend spatial subsetting packages/tasks; serve front end applications; or stand alone.

Packages and services currently requiring a spatial AOI include (but are not limited to):

[HydroData](http://mikejohnson51.github.io/HydroData/) 
[nwm](https://github.com/mikejohnson51/NWM)
[FlowlineFinder](https://github.com/mikejohnson51/FlowlineFinder)
[FedData](https://cran.r-project.org/web/packages/FedData/index.html)
[nhdplusTools](https://github.com/dblodgett-usgs/nhdplusTools)

### Installation:

```
install.packages("devtools")
devtools::install_github("mikejohnson51/nhdplusTools")
```

### Support

Package is supported with funds from the UCAR COMET program; the NOAA National Water Center; and the Universtiy of California, Santa Barbara

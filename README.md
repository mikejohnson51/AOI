# AOI: Areas of Interest <img src="man/figures/logo.png" width=130 height = 150 align="right" />

[![Build Status](https://travis-ci.org/mikejohnson51/AOI.svg?branch=master)](https://travis-ci.org/mikejohnson51/AOI) 
[![Coveralls github](https://img.shields.io/coveralls/github/mikejohnson51/AOI.svg)](https://coveralls.io/github/mikejohnson51/AOI?branch=master)
[![DOI](https://zenodo.org/badge/139353238.svg)](https://zenodo.org/badge/latestdoi/139353238)


**Welcome to the AOI R homepage!** <br>

If you've ever found yourself needing to geocode or reverse-geocode a location, formalize an area of interest, get bounding geometries, describe a place by lat/long, or better understand spatial locations, this package should be able to help. 

An area of interest (AOI) is a geographic extent. It helps confine and formalize a unit of work to a geographic area, and prioritize and define research and sub setting efforts while improving reproducibility. They are built around concrete spatail attributes but often are discussed in a more colloquail way. The aim of the is package is to help make the colloquial understanding of space more concrete in the R environment.

'AOI` lets users define regions through a common query to achieve spatial geometries that can be used in sub setting, clipping, and mapping operations. Tools are provided to help define, describe, and convert points, boundaries, and features to usable forms including strings. In principle, the AOI package helps accomplish five main tasks increasing in order of simply providing convenience to providing new functionality to the deep R spatial ecosystem. These include helping:

1. Create bounding geometries of existing `sp`, `sf`, and `raster` objects (see [here](./articles/clipAreas.html))
2. Get `sp`, or `sf`, state and county geometries and/or their bounding geometries (see [here](./articles/stateCounty.html))
3. Provide geocoding and reverse geocoding functionalities from google, OSM and ESRI
4. Create `sp` or `sf` geometries from a given location and bounding box dimensions. (see [here](./articles/clipAreas.html))
5. Map, describe and communicate AOIs to others. (see [here](./articles/tools.html))

All functions are designed to be used with the magrittr pipe operation `%>%` so that they can be easily integrated with other spatial packages in the R ecosystem (see [here](./articles/useCases.html))

### Installation:

```
install.packages("devtools")
devtools::install_github("mikejohnson51/AOI")
```

Current packages/applications using AOI:

1. [HydroData](https://github.com/mikejohnson51/HydroData)
2. [NWM](https://github.com/mikejohnson51/NWM)
3. [FlowFinder](https://github.com/mikejohnson51/FlowFinder)

### Support:

The "AOI" R package is written by [Mike Johnson](https://mikejohnson51.github.io), a graduate Student at the [University of California, Santa Barbara](https://geog.ucsb.edu) in [Keith C. Clarke's](http://www.geog.ucsb.edu/~kclarke/) Lab, 2018. <br><br>
Development is supported with funds from the [UCAR COMET program](http://www.comet.ucar.edu); the [NOAA National Water Center](http://water.noaa.gov); and the University of California, Santa Barbara and is avaliable under the [MIT license](https://opensource.org/licenses/MIT)


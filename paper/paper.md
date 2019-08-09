--- 
title: "AOI: An `R` package for converting descriptions of space to formal spatial objects“
tags:
  - R
  - reproducibility
  - workflow
- spatial
authors:
- name: J. Michael Johnson
	 orcid: 0000-0002-5288-8350
	 email: mikecp11@gmail.com
	 affiliation: 1
- name: Keith C. Clarke
	  orcid: 0000-0001-5805-6056
- affiliation: 1
affiliations:
- name: University of California, Santa Barbara
	index: 1
date: 07 August 2019
bibliography: paper.bib
---

# Introduction

An Area of Interest (AOI) is a demarcated region of the earth with significance to an analysis or user. AOIs can be complex shapes, such as a state outlines or watershed boundaries, or more simply, any geographic extent defined by minimum and maximum XY coordinates. 

In spatial data science, where data is often continuous (eg climate and satellite data), or at least larger than needed for the purpose of a study, AOIs are commonly used for subsetting. However, AOIs can also be used to produce maps, create areas of focus in  iterative scripts, interface across spatial packages, and ultimately enhance the reproducibility of spatial workflows.  While the concept of AOI  is quite simple, the process of generating AOIs in a reproducible way is not.

While many spatial packages require bounding box coordinates for data aggregations (and the creation of a POLYGON geometries in sf), very few of us can quickly identify the minimum and maximum extents of an AOI. This means we generally revert to some combination of finding a spatial file, launching Google Earth, drawing a polygon in ArcMap or QGIS, or visiting a geocoding website.  The obvious drawback to these a non-programatic workflows is the time lost and the inherent lack of reproducibility and specificity in AOI generation.  

Alternatively, most of us can quickly  describe an AOI by the features and dimensions of the area we are interested in (eg  “UCSB”, or, “the 100 square mile area surrounding Denver, Colorado”). As data science, and science as a whole transitions into more transparent sharing of methods and analysis (LOWDES) the ability to  quickly, and flexibly  generate AOIs programmatically is, if not critical, quite convenient. In this vein, AOI covers five main themes with the goal of flexible, fast, and programatic AOI creation.

1. Forward, reverse, and event/association based geocoding
2. AOI queries based on fiat boundaries
3. AOI creation from point and bounding box dimensions
4. Wrappers for common AOI processes

The remainder of this paper is structured to discuss, primarily through example, these themes. On a more technical note, AOI plays nicely with the  `raster`, `sp`, and `sf` data models but returns all features as `sf` objects in the WGS84 projection. The default length measurement in AOI is miles however any function requiring a distance input also has a km parameter that can be set to `TRUE`. Finally, all functions are designed to work with tidy and magrittr piping principles.

# 1. Geocoding

Geocoding is the process of translating between descriptions of place and XY coordinates.  AOI offers a API interface to the Open Street Map (OSM) Nominatim tool which provides search capacities by name and address. While other packages offer geocoding capabilities (eg dismo, prettymapper, ggmap, opencage) each relies on a commercial service  (Google, pickpoint.io, opencage respectively) that have limitations, user agreements, and/or API key requirements. Sticking to the core of the R and the R spatial community, reliance on a free and open source geocoding platform drove our decision to add OSM to the mix. Basic geocoding requires a character sting input and will return a data.frame of all attribute data  from the OSM database.

```r`
> str(geocode("Denver”))
'data.frame':	1 obs. of  2 variables:
 $ lat: num 39.7
 $ lon: num -105
```
`
If a user wants more information regarding the lat/lon pair, they can turn on the full return.

```r`
> str(geocode("Denver", full = T))
'data.frame':	1 obs. of  10 variables:
 $ place\_id    : int 198230466
 $ osm\_type    : chr "relation"
 $ osm\_id      : int 253750
 $ boundingbox :List of 1
  ..$ : chr  "39.6143154" "39.9142087" "-105.1098845" "-104.5996889"
 $ lat         : num 39.7
 $ lon         : num -105
 $ display\_name: chr "Denver, Denver County, Colorado, United States of America"
 $ class       : chr "place"
 $ type        : chr "city"
 $ importance  : num 0.765
```
`
In addition to attribute data, users can request point and/or bounding box realizations of a query using the  `pt` and `bb` parameters respectively (figure 1A, and B). Here bounding boxes are derived from the OSM bounding box string (seen the OSM attribute data) and point from the lat/lon pair. The geocode function can also iterate over multiple locations providing data.frame, point, and bb objects pending the function parameterization. The only difference in the case of multiple requests is that `bb=TRUE` returns the minimum bounding box of all queried points rather than the bounding area of each query (figure 1C).

![\<Figure 1: Geocoding services can provide (A) point and (B) bounding box realizations of a location. Multiple queries can be passed to the geocoding function and the retuned bounding box represents the minimum extent containing all points. \>](DraggedImage.png)

In some cases, particularly in the social sciences,  the interest in geocoding is discovering where an event occurred, or an entity is associated. Events and associations are not embedded in the OSM database as they are ephemeral. As such `AOI` offers a Wikipedia geocoding function that tries to assign an XY coordinate to a query from on the metadata contained in the Wikipedia entry. Figure 2A-D shows instances of “Hurricane Harvey”, “JFKs Assassination”, and “NOAA”, and “I have a dream speech”. It should be noted that (as expected) there are discrepancies between locations returned by the OSM geocoding service (blue) and the Wikipedia entry (red) (Figure 2E) however they are generally negligible.  In instances where a geolocation is not found from the Wikipedia query, a list of alternative queries are supplied from pages linked to the original query (Figure 2F). 

![Figure 2: The geocode\_wiki function attempts to scape locational information from the associated wikipedia page. Events (A-D) can be queried. It should be noted that the OSM and Wikipedia locations are not exact but are largely the same (E) and when locational information can not be found for a specific query, a list of alternatives derived from linked pages are offered (F). ](Figure2.png)

In contrast to converting descriptions of space to XY coordinates,  reverse geocoding converts XY locations to known address and/or place. While less useful in the contexts of AOI creation, the aim of providing a complete geocoding service within AOI necessitates the inclusion of a reverse geocoding service.  Moreover, to our knowledge, this is the only reverse geocoding service avialable in the R ecosystem. AOI provides and interface to the OSM Nominatim API and ESRI API. As an example, we request the attribute data of location c(-37, -120).

```r`
> str(revgeocode(c(37,-119)))
List of 19
 $ place\_id    : int 352144
 $ osm\_type    : chr "node"
 $ osm\_id      : int 150949694
 $ lat         : chr "36.9693904"
 $ lon         : chr "-119.0173346"
 $ display\_name: chr "Sawmill Flat, Fresno County, California, USA"
 $ hamlet      : chr "Sawmill Flat"
 $ county      : chr "Fresno County"
 $ state       : chr "California"
 $ country     : chr "USA"
 $ bb          : chr "-119.0573346,-118.9773346,36.9293904,37.0093904"
 $ match\_addr  : chr "93664, Shaver Lake, California"
 $ longlabel   : chr "93664, Shaver Lake, CA, USA"
 $ shortlabel  : chr "93664"
 $ addr\_type   : chr "Postal"
 $ city        : chr "Shaver Lake"
 $ lon         : int -119
 $ lat         : int 37
 $ wkid        : int 4326
 - attr(*, "class")= chr [1:2](#) "geoloc" "list”*
````

# 2. Fiat boundary queries

Where geocoding converts point-based descriptive space to XY space we also need a method for converting descriptive space to XY area representations. One of the more common area representations used are predefined fiat boundaries. While shapefiles of these features certainly exist across the web, there use is not always streamlined and may require the need to download, unzip, import,  and subset files stored in a myriad of formats. To remove some these steps, `AOI` delivers a set of lightweight datasets that can be queried with the `getAOI()` function. The USA boundaries provided  are a simplified version of the USAboundaries (CITE) dataset and countries come from the thematicmapping.org (CITE). Examples of fiat boundary queries, including some of their variations can be seen in figure 3:

![Figure 3: (A) getAOI facilitates queries for (A) countries (B) states (C) and state-county pairs. Variations allow for the extraction of the lower 48 state (D) all counties in a given state set (E) and the option to union all requested objects in to a single unit (F). ](Figure3.png)

# 3. Point and bounding box queries

In addition to querying known boundaries, `getAOI` allows users to generate unique AOIs through a set of parameters. 

At a minimum, `getAOI` requires a place name from which the OSM boundary is defined, the result is analogous to `geocode(XXX, bb = T)`(Figure 4A). To exert more control over the dimensions of the bounding box, users can specify a height and width (in miles). Such a bounding box is, by default, drawn treating the location as the centroid (Figure 4B). Alternatively a user can specify the relative location of the point to the queried bounding box selecting between “upper left”, “lowerleft”, “upperright”, “lowerright” and “center” (Figure 4C). Iterations on these calls can include providing a lat/lon pair instead of a place name, or setting the units of the bounding box dimensions to kilometers via km = TRUE.

![Figure 4: The getAOI() function allows users to define unique subsets of space from a number of inputs. At minimum a location name (A). In addition bounding box diminsions (B)  and the relative location of the point to the bounding box (C) can be used to refine a query.](Figure4.png)

# 4. Tools for AOI manipulation

Through our own research and discussions with others using this package we have found a common set of tasks central to AOI workflows. All of these are possible through other packages such as `sf` and `leaflet` but require a few lines of code to execute. Given the pervasive, and repetitive nature of these tasks, `AOI` offers a number of wrappers to speed up AOI manipulation. 

The `is_inside` fucntion checks if one of the input geometries is completely contained within the other. There is no preference given to order of inputs and the return is a binary TRUE/FALSE. The `modify` function allows users to refine existing extents by adding or subtracting a distance from all edges.  Such an operation is analogous to `st_buffer` with the exception that `modify` takes input units as miles or kilometers as opposed to units of the projection.

```r`
> getAOI("Denver") %\>% bbox\_st()
  xmin       ymin       xmax       ymax 
-105.10988   39.61432 -104.59969   39.91421 
> modify(getAOI("Denver"), 10) %\>% bbox\_st()
  xmin       ymin       xmax       ymax 
-105.29786   39.46716 -104.41172   40.06136 
> modify(getAOI("Denver"), -10) %\>% bbox\_st()
  xmin       ymin       xmax       ymax 
-104.92078   39.75702 -104.78880   39.77151 
```
`
Often there is a need to simply get the bounding box of an existing spatial resource albeit raster, sp or sf. This is particularly useful in studies that iterate over a set of feature (eg fire polygons, watersheds, river networks, or counties). In these cases, `getBoundingBox` simply returns the minimum bounding extent of the input object(s). Conversations to translate between vector and spatial representations are available. 

Finally `check`is a leaflet wrapper that generates a interactive map of the point or boundary queried. All images in the paper were created by piping the AOI to `check()` (eg `AOI = getAOI("Denver") %>% check()`.

In addition of providing programatic workflow for creating AOIs, one of the principle goals of this package is to enhance the reproducibility of AOI workflows without needing to read, write, and share spatial files. This is first achieved by allowing AOIs to be generated and queries from within scripts. However, there is often a need a verbally describe the AOI used. In cases where the AOI was not created via getAOI() the `describe` function works to convert a spatial object into the AOI parameters needed to replicate the extent.

```r`
> r = raster(system.file("external/test.grd", package="raster"))
> str(describe(r))
'data.frame':	1 obs. of  6 variables:
 $ lat   : num 51
 $ lon   : num 5.74
 $ height: num 2.86
 $ width : num 1.99
 $ origin: chr "center"
 $ units : chr "miles"
```
`
# Conclusion

Already AOI supports a number of in-development R packages including NWM, HydroData, climateR.  Moreover, AOI is primed to work with a wide array of existing CRAN packages that require spatial extents as input. These include but are certainly not limited to: *feddata, rosm, ray shader, elevatr, soilDB, osmdata, raster, geoknife, sharpshooter, ceramic*. Working examples for each of these along with full AOI documentation can be found at [https://mikejohnson51.github.io/AOI](https://mikejohnson51.github.io/AOI/articles/useCases.html).

AOI has also proven useful in map-based Shiny applications seeking to provide geocoding search functionality, and map centering and zoom extents. One example of this is the FlowFinder which is a tools for visualizing local hydrography and hydrology in the United States.

The first aim of AOI was to provide fast, flexible, and programatic methods for generating AOI saving users time, and hopefully encouraging greater reproducibility in spatial data science workflows.  The use of AOI will allow users to more easily populate required information for packages interfacing with spatial databased; utilize spatial boundaries in their own workflows; and  

From a developers perspective, we have found AOI allows for consistent function inputs (in the form of coordinate reference systems, class, etc) removing some of the challenges with formatting larges spatial queries to distributed data repositories via as THREDDS/OPeNDAP servers, Web Coverages (geoservers), and tiled distributions (eg AWS). 

`getAOI(state = “CA”) %>% HydroData::findNHD()`
`getAOI(state = “CA”) %>% climateR::getPRISM(param = "prcp", startDate = "2018-10-10")`


The idea driving this need is that as more and more spatial (and point based observation) datasets expand to being delivered via web-based services including: XML (USGS NWIS), OPeNDAP (climate, National Water Model data), Web Coverage Services (NHD, NLCD), tiled raster products (NED, NLCD), and REST services (WBD), the ability to make fast, web based queries is becoming  a staple in the way data is/can be delivered for research and analysis. The challenge with this is that each service demands a unique request format (eg url call), specific posting of the data; and coordinate based geo sub setting descriptions. The first two of these, that is the automation of url generation and post processing set the ideal stage for creating an R package. The last however, defining the sub setting coordinates, is a bit more abstract. It can be generalized in a way that a spatial object can be parsed into the appropriate strings, however this again requires that a user is in possession of a spatial geometry file of there unique AOI. 

# Availability
`AOI` is open source software made available under the MIT license. It can be installed  from its GitHub repository using the `devtools` package: `devtools::install_github("mikejohnson51/AOI")`.

# Acknowledgements

The AOI package was developed under the UCAR and National Water Center COMET program (2018/2019).

# References

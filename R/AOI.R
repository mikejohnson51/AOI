#' AOI
#'
#' \code{AOI} package
#'
#' The area of interest (AOI) is the geographic extent of a project.
#' This helps confine the unit of work to a geographic area, and helps to not only proritize and define research and subsetting efforts,
#' but to improve reproducabilty across studies. This package aims to make finding state, county and geographic AOI easier,
#' through a common query system based on 'state', 'county' and 'clip' parameters. AOIs for all queryies are retruned a a SpatialPolygon.
#'
#' See the README on github
#'
#' @docType package
#' @name AOI
#'
#' @importFrom  leaflet leaflet addProviderTiles addScaleBar addMeasure addLayersControl addPolygons
#' @importFrom  sp Polygon SpatialPolygons spTransform Polygons
#' @importFrom  sf st_geometry as_Spatial
#' @importFrom  dplyr %>%
#' @importFrom  dismo geocode
#' @importFrom  stats setNames
#' @importFrom  utils capture.output tail install.packages
#' @importFrom  USAboundaries us_counties us_states
#' @importFrom  raster rasterToPolygons

NULL

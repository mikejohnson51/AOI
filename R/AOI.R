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
#'
#' @name AOI
#'
#' @import      leaflet
#' @importFrom  sp Polygon SpatialPolygons spTransform Polygons CRS
#' @importFrom  dismo geocode
#' @importFrom  utils capture.output tail install.packages
#' @importFrom  raster rasterToPolygons

NULL

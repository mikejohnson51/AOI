#' @title AOI
#' @description \code{AOI} package
#' The area of interest (AOI) is the geographic extent. It helps confin the unit of work to a geographic area,
#' tproritize and define research and subsetting efforts, and to improve reproducabilty across studies.
#' This package aims to make finding fiat and geographic AOIs easier,
#' through a common query system based on 'state', 'county' and 'clip' parameters.
#' AOIs for all queryies are retruned a a SpatialPolygon projeted to EPSG:4269.
#'
#' See the \href{https://github.com/mikejohnson51/AOI/blob/master/README.md}{README} on github
#'
#' @docType package
#'
#' @name AOI
#'
#' @import      leaflet
#' @importFrom  sp Polygon SpatialPolygons spTransform Polygons CRS
#' @importFrom  utils tail
#' @importFrom  raster rasterToPolygons
#' @importFrom  sf st_as_sf as_Spatial st_bbox st_transform
#' @importFrom  xml2 read_xml xml_children xml_attrs

NULL



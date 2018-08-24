#' @title AOI Package
#' @description An area of interest (AOI) is a geographic extent and the aim of this package is to help users create these. The package is written using the simple features  paradigm, however, by default, objects are returned as \code{SpatialPolygons} projected to EPSG:4269.
#' For those that have made the jump to sf, all functions include a 'sf' parameter that can be set to TRUE and eventully the default behavior will change.\cr
#'
#'
#' The primary functions to be aware of are \code{\link{geocode}}, \code{\link{getAOI}}, \code{\link{getBoundingBox}}.
#' The first returns a set spatial points, the second a single spatial geometry, and the last a geometry encompassing all input features. \code{\link{bbox_st}} and \code{\link{bbox_sp}} help convert AOIs between string and geometry  manifestations; \code{\link{check}} helps users visualize AOIs in a interactive leaflet map; and \code{\link{buffer}} allows for the modification of AOIs by uniform distances.
#' Finally, \code{\link{revgeocode}} provides a reverse geocoding interface to help understand coordinates as locations, and \code{\link{describe}} breaks existing spatial features into getAOI parameters to improve the reproducibility of geometry generation.
#' \cr
#'
#' Two core datasets are served with the package reflecting the spatial geometries of US \code{\link{states}} and \code{\link{counties}}.
#' \cr
#'
#' See the \href{https://github.com/mikejohnson51/AOI/blob/master/README.md}{README} on github, and a webpage of examples \href{https://mikejohnson51.github.io/AOI/}{here}.
#'
#' @docType package
#' @name AOI
#' @import      leaflet
#' @importFrom  jsonlite fromJSON
#' @importFrom  utils tail
#' @importFrom  sf st_as_sf as_Spatial st_bbox st_transform st_sfc st_polygon
#' @importFrom  xml2 read_xml xml_children xml_attrs

NULL


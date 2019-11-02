#' @title AOI Package
#' @description An area of interest (AOI) is a geographic extent. The aim of this package is to help users create these - essentailly turning locations, place names, and political boundaries
#' into servicable geometries for spatial analysis. The package is written using the simple features paradigm, projected to EPSG:4269.\cr
#'
#' The primary functions in this package are are \code{\link{geocode}}, \code{\link{revgeocode}}, \code{\link{getAOI}}, and \code{\link{getBoundingBox}}.
#' The first returns a data.frame of corrdinates from place names using the OSM API; the second returns a list of descriptive features from a known place name or lat/lon pair;
#' the third returns a spatial (sf) geometry from a country, state, county, or defined region, and the last an extent encompassing a set of input features.
#' Addtional helper functions include \code{\link{bbox_st}} and \code{\link{bbox_sp}} which help convert AOIs between string and geometries;
#' \code{\link{check}} which helps users visualize AOIs in a interactive leaflet map; and \code{\link{modify}} which allows AOIs to be midified by uniform distances.
#' Finally, \code{\link{describe}} breaks existing spatial features into \code{\link{getAOI}} parameters to improve the reproducibility of geometry generation.
#' \cr
#'
#' Three core datasets are served with the package. The first contains the spatial geometries and attributes of all \code{\link{world}} countries. The second, the spatial geometries for US \code{\link{states}}
#' and the third contains the same for all US \code{\link{counties}}.
#' \cr
#'
#' See the \href{https://github.com/mikejohnson51/AOI/blob/master/README.md}{README} on github, and the project webpage for examples \href{https://mikejohnson51.github.io/AOI/}{here}.
#'
#' @docType package
#' @name AOI
#' @import      leaflet
#' @importFrom  dplyr select mutate
#' @importFrom  jsonlite fromJSON
#' @importFrom  sf st_as_sf as_Spatial st_bbox st_transform st_sfc st_polygon st_crs st_geometry_type st_buffer
#' @importFrom  rvest html_nodes html_text html_attr html_table
#' @importFrom  xml2  read_html
#' @importFrom  stats complete.cases
#' @importFrom  utils globalVariables

utils::globalVariables(c(".data"))

NULL

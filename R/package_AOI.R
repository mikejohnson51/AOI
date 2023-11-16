#' @title AOI Package
#' @description
#' An area of interest (AOI) is a geographic extent.
#' The aim of this package is to help users create these -
#' turning locations, place names, and political boundaries
#' into servicable representation for spatial analysis.
#' The package defaults to EPSG:4326\cr
#'
#' See the \href{https://github.com/mikejohnson51/AOI}{README} on github,
#' and the project webpage for examples
#' \href{https://mikejohnson51.github.io/AOI/}{here}.
#'
#' @docType package

#' @importFrom tidygeocoder geo reverse_geo
#' @importFrom dplyr `%>%` select contains mutate rename any_of
#' @importFrom sf st_union st_transform st_as_sf st_bbox st_area st_as_sfc st_is st_sf st_sfc st_polygon st_cast st_geometry_type st_crs st_buffer st_drop_geometry st_point st_set_crs st_is_longlat
#' @importFrom rvest html_nodes html_nodes html_text html_nodes html_table
#' @importFrom jsonlite fromJSON
#' @importFrom rnaturalearth ne_countries
#' @importFrom units set_units
#' @importFrom fipio fips_metadata

default_crs = 4326
default_method = "arcgis"
default_units = "meter"
default_dim = c(512)

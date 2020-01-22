#' @title AOI Package
#' @description An area of interest (AOI) is a geographic extent. The aim of this package is to help users create these -  turning locations, place names, and political boundaries
#' into servicable geometries for spatial analysis. The package is written using the simple features paradigm, projected to EPSG:4269.\cr
#'
#' The primary functions are \code{\link{geocode}}, \code{\link{geocode_rev}}, \code{\link{aoi_get}}, and \code{\link{bbox_get}}.
#' The first returns a data.frame of corrdinates from place names using the OSM API; the second returns a list of descriptive features from a known place name or lat/lon pair;
#' the third returns a spatial (sf) geometry from a country, state, county, or defined region, and the last an extent encompassing a set of input features.
#' \code{\link{aoi_map}} helps users visualize AOIs in a interactive map; and \code{\link{aoi_buffer}} which allows AOIs to be modified by uniform distances.
#' Finally, \code{\link{aoi_describe}} breaks existing spatial features into \code{\link{aoi_get}} parameters to improve the reproducibility of geometry generation.
#' \cr
#'
#' See the \href{https://github.com/mikejohnson51/AOI}{README} on github, and the project webpage for examples \href{https://mikejohnson51.github.io/AOI/}{here}.
#'
#' @docType package
#' @name AOI
#'
#' @import      leaflet
#' @importFrom  dplyr select mutate bind_rows
#' @importFrom  jsonlite fromJSON
#' @importFrom  sf st_as_sf st_sf as_Spatial st_bbox st_transform st_sfc st_polygon st_crs st_geometry_type st_buffer st_intersection
#' @importFrom  rvest html_nodes html_text html_attr html_table
#' @importFrom  xml2  read_html
#' @importFrom  stats complete.cases na.omit setNames
#' @importFrom  utils globalVariables
#' @importFrom  rnaturalearth ne_countries
#' @importFrom  USAboundaries us_boundaries us_counties us_zipcodes
#' @importFrom  methods is


NULL

utils::globalVariables(
  c('LongLabel', 'ShortLabel', 'country_code', 'display_name')
)


states    = USAboundaries::us_states() %>%
  merge(data.frame(
      state_abbr = state.abb,
      region = as.character(state.region),
      stringsAsFactors = F),
    all.x = TRUE
  ) %>%
  st_transform(4269)

counties  = USAboundaries::us_counties() %>% st_transform(4269)
zipcodes  = USAboundaries::us_zipcodes() %>% st_transform(4269)
countries = rnaturalearth::ne_countries(returnclass = "sf") %>% st_transform(4269)

#' @title AOI Projection
#' @description  Projection used for all AOI objects: \emph{EPSG:4269}. `aoiProj = "+init=epsg:4269"`
#' @export
#' @author Mike Johnson

aoiProj = 4269











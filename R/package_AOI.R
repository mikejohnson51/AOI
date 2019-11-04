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
#' Three core datasets are served with the package. The first contains the spatial geometries and attributes of all \code{\link{countries}} countries. The second, the spatial geometries for US \code{\link{states}}
#' and the third contains the same for all US \code{\link{counties}}.
#' \cr
#'
#' See the \href{https://github.com/mikejohnson51/AOI}{README} on github, and the project webpage for examples \href{https://mikejohnson51.github.io/AOI/}{here}.
#'
#' @docType package
#' @name AOI
#' @import      leaflet
#' @importFrom  dplyr select mutate
#' @importFrom  jsonlite fromJSON
#' @importFrom  sf st_as_sf st_sf as_Spatial st_bbox st_transform st_sfc st_polygon st_crs st_geometry_type st_buffer st_intersection
#' @importFrom  rvest html_nodes html_text html_attr html_table
#' @importFrom  xml2  read_html
#' @importFrom  stats complete.cases na.omit setNames
#' @importFrom  utils globalVariables

NULL

utils::globalVariables(
  c(".data", "zipcodes", "state.abb",
    "state.name", "states", "countries",
    "counties")
)

#' @title AOI Projection
#' @description  Projection used for all AOI objects: \emph{EPSG:4269}. `aoiProj = "+init=epsg:4269"`
#' @export
#' @author Mike Johnson

aoiProj = '+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs'

#' @title USA States
#' @description Dataset containing polygon representations of USA States.
#' @docType data
#' @format a simple feature polygon set with 52 observations of 5 variables:
#' \itemize{
#' \item 'statefp'   :  \code{character}  2-digit Federal Information Processing Standards (FIPS) code
#' \item 'statens'   :  \code{character}  American National Standards Institute (ANSI) code
#' \item 'affgeoid'  :  \code{character}  American FactFinder (AFF) Summary Level Code
#' \item 'state_name':  \code{character}  State Name
#' \item 'state_abbr':  \code{character}  State Abbriviation
#' }
#' @examples
#' \dontrun{
#' AOI::states
#'}

"states"

#' @title USA Counites
#' @description Dataset containing polygon representations of USA Counties.
#' @docType data
#' @format a \code{SpatialPolygonsDataFrame}, 3220 observations of 7 variables:
#' \itemize{
#' \item 'statefp'   : \code{character} 2-digit Federal Information Processing Standards (FIPS) code
#' \item 'countyfp'  : \code{character} 3-digit Federal Information Processing Standards (FIPS) code
#' \item 'affgeoid'  : \code{character} American FactFinder (AFF) Summary Level Code
#' \item 'geoid'     : \code{character} Concatinates state and county FIP code
#' \item 'name'      : \code{character} County name
#' \item 'state_name': \code{character} State name
#' \item 'state_abbr': \code{character} State Abbriviation
#' }
#' @examples
#' \dontrun{
#'  AOI::counties
#'}

"counties"

#' @title Simplified World Boundaries
#' @description Dataset containing simpified polygons of World Countries and Regions. Data is initalized from \href{http://thematicmapping.org/downloads/world_borders.php}{thematicmapping.org}.
#' @docType data
#' @format a \code{SpatialPolygonsDataFrame}, 246 observations of 11 variables:
#' \itemize{
#' \item 'FIPS'     :  \code{character} FIPS 10-4 Country Code
#' \item 'ISO2'     :  \code{character} ISO 3166-1 Alpha-2 Country Code
#' \item 'ISO3'     :  \code{character} ISO 3166-1 Alpha-3 Country Code
#' \item 'UN'       :  \code{integer}   ISO 3166-1 Numeric-3 Country Code
#' \item 'NAME'     :  \code{character} Name of country/area
#' \item 'AREA'     :  \code{integer}   Land area, FAO Statistics (2002)
#' \item 'POP2005'  :  \code{numeric}   Population, World Population Prospects (2005)
#' \item 'REGION'   :  \code{integer}   Macro geographical (continental region), UN Statistics
#' \item 'SUBREGION':  \code{integer}   Geographical sub-region, UN Statistics
#' \item 'LON'      :  \code{numeric}   Longitude
#' \item 'LAT'      :  \code{numeric}   Latitude
#' }
#' @source \href{http://thematicmapping.org/downloads/world_borders.php}{thematicmapping.org}
#' @examples
#' \dontrun{
#'  AOI::countries
#'}

"countries"


#' @title USA Zipcode Database
#' @description Dataset containing information for USA Zipcodes. Data is initalized from \href{https://www.boutell.com/zipcodes/}{Tom Boutell}
#' @docType data
#' @format a \code{data.frame}, 43191 rows of 7 variables:
#' \itemize{
#' \item 'zip'     :  \code{integer} Zipcode
#' \item 'city'     :  \code{character} City Name
#' \item 'state'     :  \code{character} State Name
#' \item 'latitude'       :  \code{numeric}   latitude
#' \item 'longitude'     :  \code{numeric} longitude
#' \item 'timezone'     :  \code{integer}  timezone (from UTC)
#' \item 'dst'  :  \code{integer}   Daylights time saving flag (1 = Observed,  0 = Not Observed)
#' }
#' @source \href{https://www.boutell.com/zipcodes/}{Tom Boutell}
#' @examples
#' \dontrun{
#'  AOI::zipcodes
#'}

"zipcodes"

#' @title USA Zipcode Database
#' @description Dataset containing information for USA Zipcodes. Data is initalized from \href{https://www.boutell.com/zipcodes/}{Tom Boutell}
#' @docType data
#' @format a \code{data.frame}, 233 rows 149variables:
#' @source \href{https://www.naturalearthdata.com/downloads/50m-cultural-vectors/50m-admin-0-countries-2/}{Natural Earth}. The data is joined to a working database of the
#' @source \href{https://www.cia.gov/library/publications/the-world-factbook/}{CIA World Factbook}.
#' @examples
#' \dontrun{
#'  AOI::zipcodes
#'}

"zipcodes"




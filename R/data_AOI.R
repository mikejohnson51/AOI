#' @title USA States
#' @description Dataset containing \code{SpatialPolygons} of USA States. Data is initalized from the USAboundaries and USAboundariesData
#' package, converted to \code{SpatialPolygons}, re-projected and cleaned-up for this package. The primary reason for doing this is to provide
#' a more minimalistic dataset primed for this package and leaflet use.
#' @docType data
#' @format a \code{SpatialPolygonsDataFrame}, 52 observations of 5 variables:
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
#' @description Dataset containing \code{SpatialPolygons} of USA Counties. Data is initalized from the USAboundaries and USAboundariesData
#' package, converted to \code{SpatialPolygons}, re=projected and cleaned-up for this package. The primary reason for doing this to provide
#' a more minimalistic dataset primed for this package and leaflet use.
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
#' @description Dataset containing \code{SpatialPolygons} of World Countries and Regions. Data is initalized from \href{http://thematicmapping.org/downloads/world_borders.php}{thematicmapping.org}
#' package, converted to \code{SpatialPolygons} and reprojected for this package.
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
#'  AOI::world
#'}

"world"


#' @title USA Zipcode Database
#' @description Dataset containing information for USA Zipcodes. Data is initalized from \href{https://www.boutell.com/zipcodes/}{Tom Boutell}
#' @docType data
#' @format a \code{csv}, 246 43191 of 7 variables:
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

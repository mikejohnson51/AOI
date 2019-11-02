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
#'  AOI::world
#'}

"world"


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
#' @source \href{https://www.naturalearthdata.com/downloads/50m-cultural-vectors/50m-admin-0-countries-2/}{Natural Earth}. The data is joined to a working database of the CIA
#' @source \href{https://www.cia.gov/library/publications/the-world-factbook/}{World Factbook}.
#' @examples
#' \dontrun{
#'  AOI::countries
#'}

"countries"

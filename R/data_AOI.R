#' @title USA States
#' @description Dataset containing \code{SpatialPolygons} of USA States. Data is initalized from the USAboundaries and USAboundariesData
#' package, converted to \code{SpatialPolygons}, re-projected and cleaned-up for this package. The primary reason for doing this is to provide
#' a more minmualistic dataset dataset primed for this package and leaflet use.
#' @docType data
#' @format a \code{SpatialPolygonsDataFrame}, 52 observations of 5 variables
#' \itemize{
#' \item 'statefp':    A \code{character}  State 2-digit FederalInformationProcessingStandards (FIPS) code
#' \item 'statens':    A \code{character}  American National Standards Institute (ANSI) code
#' \item 'affgeoid': A \code{character}    AFF Summary Level Code
#' \item 'state_name':    A \code{character}    State Name
#' \item 'state_abbr':     A \code{character}    State Abbriviation
#' }
#' @source  \href{https://cran.r-project.org/web/packages/USAboundaries/index.html}{USAboundaries}
#' @examples
#' \dontrun{
#' AOI::states
#'}

"states"

#' @title USA Counites
#' @description Dataset containing \code{SpatialPolygons} of USA Counties. Data is initalized from the USAboundaries and USAboundariesData
#' package, converted to \code{SpatialPolygons}, re=projected and cleaned-up for this package. The primary reason for doing this to provide
#' a more minmualistic dataset dataset primed for this package and leaflet use.
#' @docType data
#' @format a \code{SpatialPolygonsDataFrame}, 3220 observations of 7 variables
#' \itemize{
#' \item 'statefp':    A \code{character}  State 2-digit FederalInformationProcessingStandards (FIPS) code
#' \item 'countyfp':    A \code{character} County 3-digit FederalInformationProcessingStandards (FIPS) code
#' \item 'affgeoid': A \code{character}  AFF Summary Level Code
#' \item 'geoid':    A \code{character}  Concatinates state and county FIP code
#' \item 'name':     A \code{character}    County name
#' \item 'state_name':    A \code{character}    State name
#' \item 'state_abbr':     A \code{character}    State Abbriviation
#' }
#' @source  \href{https://cran.r-project.org/web/packages/USAboundaries/index.html}{USAboundaries}
#' @examples
#' \dontrun{
#'  AOI::counties
#'}

"counties"


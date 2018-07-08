#' USA States
#'
#' Dataset containing \code{SpatialPolygons} of USA States. Data is taken from the USAboundaries and USAboundariesData
#' package, converted to spatial \code{sp} objects, and cleaned-up for this packages purposes.
#'
#' #' The primary reason for doing this is because of the challenges associated with using the USAboundariesData as a dependency for this, and other packages.
#'
#' @docType data
#'
#' @format a \code{dataframe} instance, 1 row per station with columns:
#' \itemize{
#' \item 'statefp':    A \code{character}  State 2-digit FederalInformationProcessingStandards (FIPS) code
#' \item 'statens':    A \code{character}  American National Standards Institute (ANSI) code
#' \item 'affgeoid': A \code{character}    AFF Summary Level Code
#' \item 'state_name':    A \code{character}    State Name
#' \item 'state_abbr':     A \code{character}    State Abbriviation
#' }
#'
#' @source  \href{https://cran.r-project.org/web/packages/USAboundaries/index.html}{USAboundaries}
#'
#' @examples
#' \dontrun{
#'  states = AOI::states
#' }

"states"

#' USA Counites
#'
#' Dataset containing \code{SpatialPolygons} of USA Counties Data is taken from the USAboundaries and USAboundariesData
#' package, converted to spatial \code{sp} objects,  and cleaned-up for this packages purposes.
#'
#' The primary reason for doing this is because of the challenges associated with using the USAboundariesData as a dependency for this, and other packages.
#'
#' @docType data
#'
#' @format a \code{dataframe} instance, 1 row per station with columns:
#' \itemize{
#' \item 'statefp':    A \code{character}  State 2-digit FederalInformationProcessingStandards (FIPS) code
#' \item 'countyfp':    A \code{character} County 3-digit FederalInformationProcessingStandards (FIPS) code
#' \item 'affgeoid': A \code{character}  AFF Summary Level Code
#' \item 'geoid':    A \code{character}  Concatinates state and county FIP code
#' \item 'name':     A \code{character}    County name
#' \item 'state_name':    A \code{character}    State name
#' \item 'state_abbr':     A \code{character}    State Abbriviation
#' }
#'
#' @source  \href{https://cran.r-project.org/web/packages/USAboundaries/index.html}{USAboundaries}
#'
#' @examples
#' \dontrun{
#'  states = AOI::counties
#' }

"counties"


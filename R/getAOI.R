#' @title Get Area of Interest (AOI) geometry
#' @description Get a Spatial* representation of an AOI defined by:
#' \enumerate{
#'              \item  a US state name(s)
#'              \item  a US state, county pair(s)
#'              \item  a user Spatial, sf or raster object or
#'              \item  a clipping unit (see details)
#'              }
#' \code{getAOI} wraps \code{\link{getFiat}} and \code{\link{getClip}} into a single function.
#' @param state     \code{character}.  Full name or two character abbriviation. Not case senstive
#' @param county    \code{character}.  County name(s). Requires \code{state} input. Not case senstive
#' @param clip      \code{Spatial} object, a \code{Raster} object, or a \code{list} (see details and \code{\link{getClip}})
#' @param km        \code{logical}. If \code{TRUE} distance are in kilometers,  default is \code{FALSE} and with distances in miles
#' @param sf        \code{logical}. If \code{TRUE} object returned is of class sf,  default is \code{FALSE} and returns class SpatialPolygons
#' @param bb        \code{logical}. If \code{TRUE} then the bounding geometry of state/county is returned,  default is \code{FALSE} and returns fiat geometries
#' @details If \code{clip} is a list, a clip unit requires a minimum of 3 inputs:
#'                               \enumerate{
#'                                      \item  A point: \itemize{
#'                                             \item  'location name' ex: "UCSB"
#'                                             \item lat/lon pair: ex: '-36, -120'
#'                                          }
#'                                      \item  A bounding box height \itemize{
#'                                              \item{in miles} ex: 10
#'                                          }
#'                                      \item A bounding box width \itemize{
#'                                              \item{in miles} ex: 10
#'                                          }
#'                                      }
#'
#'                                      The bounding box is always drawn in relation to the location. By default the point is treated
#'                                      as the center of the box. To define the realtive location of the point to the bounding box
#'                                      a fourth input can be used:
#'                                      \enumerate{
#'                                      \item Origin \itemize{
#'                                         \item 'center' (default)
#'                                         \item 'upperleft'
#'                                         \item 'upperright'
#'                                         \item 'lowerleft'
#'                                         \item 'lowerright'
#'                                      }
#'                                  }
#' 3 to 5 elements can be used to paramaterize the \code{clip} element but \strong{ORDER MATTERS} (point, height, width, origin).
#' Acceptable variations include:
#' \itemize{
#'                                     \item 3 members: (1) location name, (2) height, (3) width \itemize{
#'                                         \item \emph{list("UCSB", 10, 10) }}
#'                                     \item 4 members: (1) latitude, (2) longitude, (3) height, (4) width\itemize{
#'                                         \item \emph{list(36, -120, 10, 10) }}
#'                                     \item 4 members: (1) location name, (2) height, (3) width, (4) origin\itemize{
#'                                         \item \emph{list("UCSB", 10, 10, "lowerright) }}
#'                                     \item 5 members: (1) lat, (2) long, (3) height, (4) width, (5) origin\itemize{
#'                                         \item \emph{list(36,-120, 10, 10, "upperright) }}
#'                                     }
#'
#' @return a geometry projected to \emph{EPSG:4269}.
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#' # Get AOI defined by a state(s)
#'     getAOI(state = 'CA')
#'     getAOI(state = c('CA', 'nevada'))
#'
#' # Get AOI defined by state & county pair(s)
#'     getAOI(state = 'California', county = 'Santa Barbara')
#'     getAOI(state = 'CA', county = c('Santa Barbara', 'ventura'))
#'
#' # Get AOI defined by external spatial file:
#'     getAOI(clip = rgdal::readOGR('la_metro.shp'))
#'     getAOI(clip = raster('AOI.tif'))
#'
#' # Get AOI defined by 10 mile bounding box using lat/lon
#'     getAOI(clip = c(35, -119, 10, 10))
#'
#' # Get AOI defined by 10 mile2 bounding box using the 'KMART near UCSB' as lower left corner
#'     getAOI(clip = list('KMART near UCSB', 10, 10, 'lowerleft'))
#'}

getAOI = function(state = NULL,
                  county = NULL,
                  clip = NULL,
                  sf = FALSE,
                  km = FALSE,
                  bb = FALSE) {

  stateAbb = AOI::states$state_abbr
  stateName = AOI::states$state_name
  shp = NULL

  #------------------------------------------------------------------------------#
  # Error Catching                                                               #
  #------------------------------------------------------------------------------#
  if (!is.null(state)) {
    if (!is.null(clip)) {
      stop("Only 'state' or 'clip' can be used. Set the other to NULL")
    }
    for (value in state) {
      if (!is.character(value)) {
        stop("State must be a character value. Try surrounding in qoutes...")
      }
      if (!(toupper(value) %in% stateAbb || tolower(value) %in% tolower(stateName))) {
        stop("State not recongized. Full names or abbreviations can be used. Please check spelling.")
      }
    }
  } else {
    if (!is.null(county)) {
      stop("The use of 'county' requires the 'state' parameter be used as well.")
    }
    if (is.null(clip)) {
      stop("Requires a 'clip' or 'state' parameter to execute")
    }
  }

  #-----------------------------------------------------------------------------------#
  # Fiat Boundary Defintion (Exisiting Spatial/Raster Feature or getFiat())   #
  #-----------------------------------------------------------------------------------#

  # AOI by state

  if (all(is.null(clip), !is.null(state))) {
    shp <- getFiat(state = state, county = county, bb)
  }

  # AOI by user shapefile

  if (checkClass(clip, "Raster")){
    shp = getBoundingBox(clip)
    shp = sp::spTransform(shp, aoiProj)
    }

  if (checkClass(clip, "Spatial")) {
    shp = sp::spTransform(clip, aoiProj)
    shp = getBoundingBox(shp)
  }

  if (checkClass(clip, "sf")) {
    shp = sf::st_transform(clip, as.character(aoiProj))
    shp = getBoundingBox(shp)
  }

  #------------------------------------------------------------------------------#
  # Clip Unit Defintion  (getClipUnit() for 3,4, or 5 inputs)                    #
  #------------------------------------------------------------------------------#

  if(is.null(shp)){

        fin = defineClip(clip, km = km)

        shp <- getClip(location = fin$location,
                      width =  fin$w,
                      height = fin$h,
                      origin = fin$o)

  }

  #------------------------------------------------------------------------------#
  # Return AOI                                                                   #
  #------------------------------------------------------------------------------#

  #message("AOI defined as ", firstLower(nameAOI(state, county, clip, km = km)))

  if(sf){ shp = sf::st_as_sf(shp) }

  return(shp)

}



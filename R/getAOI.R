#' Get Area of interest (AOI) boundary
#'
#' @description
#' The core of  all \code{AOI} functions is a bounding area. This area can be defined by (1) US state name(s),
#' (2) US county name(s), or a uniqe bounding box. The parameters used in \code{getAOI} are the same as all \code{AOI}
#'
#' @param state     character.  Full name or two character abbriviation. Not case senstive
#' @param county    character.  County name(s). Requires \code{state} input. Not case senstive
#' @param clip SpatialObject* or list. If a list, a clip unit requires 3 inputs:
#'                               \enumerate{
#'                                      \item  A point: \itemize{
#'                                             \item  'location name' ex: "UCSB"
#'                                             \item 'latitude, longitude' pair: ex: '-36, -120'
#'                                          }
#'                                      \item  Bounding box diminsions \itemize{
#'                                      \item  A bounding box height \strong{in miles} ex: 10
#'                                      \item A bounding box width \strong{in miles} ex: 10
#'                                      }
#'                                      \item The realtive location of the point to the bounding box \itemize{
#'                                         \item 'center', 'lowerleft', 'lowerright', 'upperright', 'upperleft'
#'                                         \item Default is: 'center'
#'                                      }
#'                                  }
#' 3 to 5 elements can be used to describe and refine these inputs but \strong{ORDER MATTERS (point, height, width, origin)}.
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
#' @return All AOI outputs are projected to \emph{'+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0+no_defs'}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get AOI defined by a state(s)
#'     getAOI(state = 'CA')
#'     getAOI(state = c('CA', 'nevada'))
#'
#' # Get AOI defined by state & county pair(s)
#'     getAOI(state = 'California', county = 'Santa Barbara')
#'     getAOI(state = 'California', county = c('Santa Barbara', 'ventura'))
#'
#' # Get AOI defined by external shapefile
#'     getAOI(clip = rgdal::readOGR('la_metro.shp'))
#'     getAOI(clip = raster('AOI.tif'))
#'
#' # Get AOI defined by 10 mile bounding box using users location as centroid
#'     getAOI(clip = c(get_ip_loc(), 10, 10))
#'
#' # Get AOI defined by 10 mile2 bounding box using the 'KMART near UCSB' as lower left corner
#'     getAOI(clip = list('KMART near UCSB', 10, 10))
#'     getAOI(clip = list('KMART near UCSB', 10, 10, 'lowerleft'))
#' }
#'
#' @seealso \itemize{
#'          \item \code{\link{getClip}}
#'          \item \code{\link{getFiat}}
#'          }
#'
#'
#' @author
#' Mike Johnson

getAOI = function(state = NULL,
                  county = NULL,
                  clip = NULL) {

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
      if (!(toupper(value) %in% AOI::stateAbb || tolower(value) %in% tolower(AOI::stateName))) {
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
  # Fiat Boundary Defintion (Exisiting Spatial/Raster Feature or getFiatBoundary())   #
  #-----------------------------------------------------------------------------------#

  # AOI by state

  if (is.null(clip) && !is.null(state)) {
    shp <- getFiat(state = state, county = county)
    #return(shp)
  }

  # AOI by user shapefile

  if (grepl(
    pattern = "Raster",
    class(clip),
    ignore.case = T,
    fixed = F)){

    shp =  raster::rasterToPolygons(clip) %>% spTransform(aoiProj)

    }

  if (grepl(
    pattern = "Spatial",
    class(clip),
    ignore.case = T,
    fixed = F)) {
    shp =  clip %>% spTransform(aoiProj)
  }

  #------------------------------------------------------------------------------#
  # Clip Unit Defintion  (getClipUnit() for 3,4, or 5 inputs)                    #
  #------------------------------------------------------------------------------#

  if(!exists("shp")){

   fin = defineClip(clip)

   shp <- getClip(location = fin$location,
                      width = fin$w,
                      height = fin$h,
                      origin = fin$o)
  }

  #------------------------------------------------------------------------------#
  # Return AOI                                                                   #
  #------------------------------------------------------------------------------#

  message("AOI defined as ", firstLower(nameAOI(state, county, clip)))

  return(shp)

}



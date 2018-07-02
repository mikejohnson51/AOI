#' Get Area of interest (AOI) boundary
#'
#' @description
#' The core of  all \code{AOI} functions is a bounding area. This area can be defined by (1) a US state name(s),
#' a (2) US county name(s), or a uniqe bounding box. The parameters used in \code{getAOI} are the same as all \code{AOI}
#' functions. Understanding the flexibility of \code{getAOI} allows you to 'find' and 'get' data for your region of interest.
#'
#' @param state     character.  Full name or two character abbriviation. Not case senstive
#' @param county    character.  County name(s). Requires \code{state} input. Not case senstive
#' @param clip_unit SpatialObject* or list. If a list, a clip unit requires 3 inputs:
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
#' @return All HydroData outputs are projected to \emph{'+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0+no_defs'}.
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
#'     getAOI(clip_unit = rgdal::readOGR('la_metro.shp'))
#'     getAOI(clip_unit = raster('AOI.tif'))
#'
#' # Get AOI defined by 10 mile bounding box using users location as centroid
#'     getAOI(clip_unit = c(get_ip_loc(), 10, 10))
#'
#' # Get AOI defined by 10 mile2 bounding box using the 'KMART near UCSB' as lower left corner
#'     getAOI(clip_unit = list('KMART near UCSB', 10, 10))
#'     getAOI(clip_unit = list('KMART near UCSB', 10, 10, 'lowerleft'))
#' }
#'
#' @seealso \itemize{
#'          \item \code{\link{getClipUnit}}
#'          \item \code{\link{getFiatBoundary}}
#'          }
#'
#'
#' @author
#' Mike Johnson

getAOI = function(state = NULL,
                  county = NULL,
                  clip_unit = NULL) {

  #------------------------------------------------------------------------------#
  # Error Catching                                                               #
  #------------------------------------------------------------------------------#
  if (!is.null(state)) {
    if (!is.null(clip_unit)) {
      stop("Only 'state' or 'clip_unit' can be used. Set the other to NULL")
    }
    for (value in state) {
      if (!is.character(value)) {
        stop("State must be a character value. Try surrounding in qoutes...")
      }
      if (!(toupper(value) %in% AOI::state.abb || tolower(value) %in% tolower(AOI::state.name))) {
        stop("State not recongized. Full names or abbreviations can be used. Please check spelling.")
      }
    }
  }
  else {
    if (!is.null(county)) {
      stop("The use of 'county' requires the 'state' parameter be used as well.")
    }
    if (is.null(clip_unit)) {
      stop("Requires a 'clip_unit' or 'state' parameter to execute")
    }
  }

  #-----------------------------------------------------------------------------------#
  # Fiat Boundary Defintion (Exisiting Spatial/Raster Feature or getFiatBoundary())   #
  #-----------------------------------------------------------------------------------#

  # AOI by state

  if (is.null(clip_unit) && !is.null(state)) {
    shp <- getFiatBoundary(state = state, county = county)
    #return(shp)
  }

  # AOI by user shapefile

  if (grepl(
    pattern = "Raster",
    class(clip_unit),
    ignore.case = T,
    fixed = F))
    {
    shp =  rasterToPolygons(clip_unit) %>% spTransform(AOI::HydroDataProj)
    #return(shp)
    }

  if (grepl(
    pattern = "Spatial",
    class(clip_unit),
    ignore.case = T,
    fixed = F
  )) {
    shp =  clip_unit %>% spTransform(AOI::HydroDataProj)
  }

  #------------------------------------------------------------------------------#
  # Clip Unit Defintion  (getClipUnit() for 3,4, or 5 inputs)                    #
  #------------------------------------------------------------------------------#

  if(!exists("shp")){
     fin = define.clip.unit(clip_unit)

   shp <- getClipUnit(location = fin$location,
                      width = fin$w,
                      height = fin$h,
                      origin = fin$o)
  }

  #------------------------------------------------------------------------------#
  # Return AOI                                                                   #
  #------------------------------------------------------------------------------#

  message("AOI defined as ", firstLower(nameAOI(state, county, clip_unit)))

  return(shp)

}



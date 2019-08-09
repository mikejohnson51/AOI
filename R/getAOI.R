#' @title Get Area of Interest (AOI) geometry
#' @description Generate a spatial geometry from:
#' \enumerate{
#'              \item  Country name, 2-digit or 3-digit ISO abbriviation(s)
#'              \item  US state name(s)
#'              \item  US state, county pair(s)
#'              \item  a spatial, sf or raster object
#'              \item  a clip unit (see details)
#'              }
#' @param country   \code{character}. Full name, ISO 3166-1 2 or 3 digit code. Not case senstive
#' @param state     \code{character}. Full name or two character abbriviation. Not case senstive. If \code{state = 'conus'}, the lower 48 states will be returned. If \code{state = 'all'}, all states will be returned.
#' @param county    \code{character}. County name(s). Requires \code{state} input. Not case senstive. If 'all' then all counties in a state are returned
#' @param clip      \code{spatial}. \code{raster}, \code{sf} or a \code{list} object (see details for list parameters)
#' @param km        \code{logical}. If \code{TRUE} distances are in kilometers, default is \code{FALSE} with distances in miles
#' @param bb        \code{logical}. Only applicable for country, state,  and county calls. If \code{TRUE} the bounding geometry is returned, default is \code{FALSE} and returns fiat geometries
#' @param union        \code{logical}. If TRUE objects are unioned into a single object
#' @details A \code{clip} unit can be described by just a place name (eg 'UCSB'). In doing so the associated boundaries determined by \code{\link{geocode}} will be returned.
#' To have greater control over the clip unit it can be defined as a list with a minimum of 3 inputs:
#'                               \enumerate{
#'                                      \item  A point: \itemize{
#'                                             \item  'place name' (\code{character}) ex: "UCSB" - or -
#'                                             \item 'lat/lon' pair: ex: "c(-36, -120)"
#'                                          }
#'                                      \item  A bounding box height (\code{numeric}) \itemize{
#'                                              \item{in miles} ex: 10
#'                                          }
#'                                      \item A bounding box width (\code{numeric})\itemize{
#'                                              \item{in miles} ex: 10
#'                                          }
#'                                      }
#'
#'                                      The bounding box is always drawn in relation to the point By default the point is treated
#'                                      as the center of the box. To define the realtive location of the point to the bounding box,
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
#' In total, 1 to 5 elements can be used to define \code{clip} element and \strong{ORDER MATTERS} (point, height, width, origin).
#' Acceptable variations include:
#' \itemize{
#'                                     \item 1 member: (1) place name \itemize{
#'                                         \item \emph{"UCSB"}}
#'                                     \item 1 member: (1) lat/lon pair \itemize{
#'                                         \item \emph{c(36, -119)}}
#'                                     \item 3 members: (1) location name, (2) height, (3) width \itemize{
#'                                         \item \emph{list("UCSB", 10, 10) }}
#'                                     \item 4 members: (1) lat, (2) lon, (3) height, (4) width\itemize{
#'                                         \item \emph{list(36, -120, 10, 10) }}
#'                                     \item 4 members: (1) place name, (2) height, (3) width, (4) origin\itemize{
#'                                         \item \emph{list("UCSB", 10, 10, "lowerright) }}
#'                                     \item 5 members: (1) lat, (2) lon, (3) height, (4) width, (5) origin\itemize{
#'                                         \item \emph{list(36,-120, 10, 10, "upperright) }}
#'                                     }
#' @return a spatial (sp/sf) geometry projected to \emph{EPSG:4269}.
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#' #Get AOI for a country
#'     getAOI(country = "Brazil")
#'
#' # Get AOI for a location
#'     getAOI("Sacramento")
#'
#' # Get AOI defined by a state(s)
#'     getAOI(state = 'CA')
#'     getAOI(state = c('CA', 'nevada'))
#'
#' # Get AOI defined by all states, or the lower 48
#'     getAOI(state = 'all')
#'     getAOI(state = 'conus')
#'
#' # Get AOI defined by state & county pair(s)
#'     getAOI(state = 'California', county = 'Santa Barbara')
#'     getAOI(state = 'CA', county = c('Santa Barbara', 'ventura'))
#'
#' # Get AOI defined by state & county pair(s)
#'     getAOI(state = 'California', county = 'Santa Barbara')
#'     getAOI(state = 'CA', county = c('Santa Barbara', 'ventura'))
#'
#' # Get AOI defined by state & all counties
#'     getAOI(state = 'California', county = 'all')
#'
#' # Get AOI defined by external spatial file:
#'     getAOI(sf::read_sf('./la_metro.shp'))
#'     getAOI(raster('./AOI.tif'))
#'
#' # Get AOI defined by 10 mile bounding box using lat/lon
#'     getAOI(clip = c(35, -119, 10, 10))
#'
#' # Get AOI defined by 10 mile2 bounding box using the 'KMART near UCSB' as lower left corner
#'     getAOI(clip = list('KMART near UCSB', 10, 10, 'lowerleft'))
#'}

getAOI = function(clip = NULL,
                  country = NULL,
                  state = NULL,
                  county = NULL,
                  km = FALSE,
                  bb = FALSE,
                  union =FALSE) {

  stateAbb = AOI::states$state_abbr
  stateName = AOI::states$state_name
  shp = NULL

  #------------------------------------------------------------------------------#
  # Error Catching                                                               #
  #------------------------------------------------------------------------------#

  if(is.null(country)){

  if (!is.null(state)) {
    if (!is.null(clip)) {
      stop("Only 'state' or 'clip' can be used. Set the other to NULL")
    }
    for (value in state) {
      if (!is.character(value)) {
        stop("State must be a character value. Try surrounding in qoutes...")
      }
      if (!(toupper(value) %in% c(stateAbb, 'conus', 'all') || tolower(value) %in% c(tolower(stateName),'conus', 'all'))) {
        stop("State not recongized. Full names or abbreviations can be used. Please check spelling.")
      }
    }
  } else {
    if (!is.null(county)) {
      stop("The use of 'county' requires the 'state' parameter be used as well.")
    }
    if (is.null(clip)) {
      stop("Requires a 'clip' or 'state' parameter to execute.")
    }
  }
  }

  #-----------------------------------------------------------------------------------#
  # Fiat Boundary Defintion (Exisiting Spatial/Raster Feature or getFiat())   #
  #-----------------------------------------------------------------------------------#

  # AOI by country

  if(!is.null(country)){
    shp <- getFiat(country = country)
  }

  # AOI by state

  if (all(is.null(clip), !is.null(state))) {
    shp <- getFiat(state = state, county = county, bb = bb)
  }

  # AOI by user shapefile

  if (checkClass(clip, "Raster")){
    shp = getBoundingBox(clip)
    shp = sf::st_transform(shp, aoiProj)
    }

  if (checkClass(clip, "Spatial")) {
    shp = sf::st_transform(sf::st_as_sf(clip), aoiProj)
    shp = getBoundingBox(shp)
  }

  if (checkClass(clip, "sf")) {
    shp = sf::st_transform(clip, aoiProj)
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

  if(union){ shp = sf::st_union(shp)}

  return(shp)

}



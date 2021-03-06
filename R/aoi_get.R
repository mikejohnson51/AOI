#' @title Get Area of Interest (AOI) geometry
#' @description Generate a spatial geometry from:
#' \enumerate{
#'              \item  Country name, 2-digit or 3-digit ISO abbreviation(s)
#'              \item  Country Region or Continent (e.g. South Asia, Africa)
#'              \item  US state name(s) or abbreviation(s)
#'              \item  US region (e.g. Northeast, South, North Central, West)
#'              \item  US state, county pair(s)
#'              \item  a spatial, sf or raster object
#'              \item  a clip unit (see details)
#'              }
#' @param country   \code{character}. Full name, ISO 3166-1 2 or 3 digit code. Not case senstive. Data comes from Natural Earth.
#' @param state     \code{character}. Full name or two character abbreviation Not case sensitive If \code{state = 'conus'}, the lower 48 states will be returned. If \code{state = 'all'}, all states will be returned.
#' @param county    \code{character}. County name(s). Requires \code{state} input. Not case sensitive If 'all' then all counties in a state are returned
#' @param x      \code{spatial}. \code{raster}, \code{sf} or a \code{list} object (see details for list parameters)
#' @param km        \code{logical}. If \code{TRUE} distances are in kilometers, default is \code{FALSE} with distances in miles
#' @param union        \code{logical}. If TRUE objects are unioned into a single object
#' @details A \code{x} unit can be described by just a place name (e.g. 'UCSB'). In doing so the associated boundaries determined by \code{\link{geocode}} will be returned.
#' To have greater control over the clip unit it can be defined as a list with a minimum of 3 inputs:
#'                               \enumerate{
#'                                      \item  A point: \itemize{
#'                                             \item  'place name' (\code{character}) ex: "UCSB" - or -
#'                                             \item 'lat/lon' pair: ex: "-36, -120"
#'                                          }
#'                                      \item  A bounding box height (\code{numeric}) \itemize{
#'                                              \item{in miles} ex: 10
#'                                          }
#'                                      \item A bounding box width (\code{numeric})\itemize{
#'                                              \item{in miles} ex: 10
#'                                          }
#'                                      }
#'
#'                                      The bounding box is always drawn in relation to the point. By default, the point is treated
#'                                      as the center of the box. To define the relative location of the point to the bounding box,
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
#' @return a sf geometry projected to \emph{EPSG:4269}.
#' @export
#' @examples
#' \dontrun{
#' #Get AOI for a country
#'     aoi_get(country = "Brazil")
#'
#' # Get AOI for a location
#'     aoi_get("Sacramento")
#'
#' # Get AOI defined by a state(s)
#'     aoi_get(state = 'CA')
#'     aoi_get(state = c('CA', 'nevada'))
#'
#' # Get AOI defined by all states, or the lower 48
#'     aoi_get(state = 'all')
#'     aoi_get(state = 'conus')
#'
#' # Get AOI defined by state & county pair(s)
#'     aoi_get(state = 'California', county = 'Santa Barbara')
#'     aoi_get(state = 'CA', county = c('Santa Barbara', 'ventura'))
#'
#' # Get AOI defined by state & county pair(s)
#'     aoi_get(state = 'California', county = 'Santa Barbara')
#'     aoi_get(state = 'CA', county = c('Santa Barbara', 'ventura'))
#'
#' # Get AOI defined by state & all counties
#'     aoi_get(state = 'California', county = 'all')
#'
#' # Get AOI defined by 10 mile bounding box using lat/lon
#'     aoi_get(c(35, -119, 10, 10))
#'
#' # Get AOI defined by 10 mile2 bounding box using the 'KMART near UCSB' as lower left corner
#'     aoi_get(list('KMART near UCSB', 10, 10, 'lowerleft'))
#'}


aoi_get = function(x = NULL, country = NULL, state = NULL, county = NULL, km = FALSE, union = FALSE) {

# Error Catching

  if (is.null(country)) {

    if (!is.null(state)) {

      if (!is.null(x)) { stop("Only 'state' or 'x' can be used. Set the other to NULL") }

      for (value in state) {

        if (!is.character(value)) {stop("State must be a character value.")}

        meta = list_states()

        if (!(toupper(value) %in% c(toupper(meta$abbr),
                                    toupper(meta$name),
                                    toupper(meta$region),
                                    'CONUS',
                                    'ALL'))) {
          stop("State not recongized. Full names, regions, or abbreviations can be used.")
        }
      }

    } else {
      if (!is.null(county)) { stop("The use of 'county' requires a 'state' parameter.")}
      if ( is.null(x))   { stop("Requires a 'x' or 'state' parameter to execute.")}
    }
    }

# Fiat Boundary Defintion (Exisiting Spatial/Raster Feature or getFiat())

  shp <- if (is.null(x)) {
    getFiat(country = country, state = state, county = county)
  } else if (any(
    methods::is(x, 'Raster'),
    methods::is(x, 'Spatial'),
    methods::is(x, 'sf'))) {
      st_transform(bbox_get(x), 4269)
  } else {
    getClip(x, km)
  }

# Return AOI

  if (union) { sf::st_union(shp) } else { shp }

}


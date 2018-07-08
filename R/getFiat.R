#' Get County and State SpatialPolygon(s)
#'
#' @details
#' \code{getFiat} gets a \code{SpatialPolygon} for a defiend state and/or county or those intersecting a clip_unit.
#' Fiat boundaries come from the 2017 US Census Bureau 2017 TIGER Dataset.
#'
#' All HydroData outputs are projected to \emph{'+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0+no_defs'}
#'
#' @param state     character. Full name or two character abbriviation. Not case senstive
#' @param county    character. Provide county name(s). Requires 'state' input.
#'
#' @return \code{getFiat} returns a \code{SpatialPolygon} Object
#' @export
#' @seealso \itemize{
#'          \item \code{\link{getClip}}
#'          \item \code{\link{getAOI}}
#'          }
#'
#' @family HydroData 'get' functions
#'
#' @examples
#' \dontrun{
#' # Get Single State
#'     getFiatBoundary(state = "CA")
#'
#' # Get Multi-state
#'     getFiatBoundary(state = c("CA","Utah","Nevada"))
#'
#' # Get County
#'     getFiatBoundary(state = "CA", county = "San Luis Obispo")
#'
#' # Get Muli-county
#'    getFiatBoundary(state = "CA", county = c("San Luis Obispo", "Santa Barbara", "Ventura"))
#'
#' # Get counties that intersect with defined clip_unit
#'    getFiatBoundary(clip_unit = list("UCSB", 10, 10, "lowerleft"))
#'}
#'
#' @author Mike Johnson
#'

getFiat <- function(state = NULL, county = NULL) {

  states = AOI::states
  counties = AOI::counties

  state_map = states[(state == states$state_name | state == states$state_abbr),]
  county_map = counties[(state == counties$state_name | state == counties$state_abbr),]

  if(is.null(county)) {
    map = state_map
    } else {

    county = simpleCap(county)
    check = county %in% county_map$name

    if(!all(check)) {
      bad_counties  = county[which(!(check))]
      if(nchar(state) == 2){state = states$state_name[which(states$state_abbr == state)]}
      stop(paste(bad_counties, collapse = ", "), " not a valid county in ", state, ".")
    }

    map = county_map[county == county_map$name,]

  }

  rm(states)
  rm(counties)

  return(map)

}



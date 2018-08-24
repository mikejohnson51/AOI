#' @title Get State of County Spatial Boundary
#' @details \code{getFiat} returns a \code{SpatialPolygons} object for a defiend state and/or county.
#' Boundaries come from the 2017 US Census TIGER Dataset and are projected to \emph{EPSG:4269}.
#' @param state     \code{character}. Full name or two character abbriviation. Not case senstive
#' @param county    \code{character}. Provide county name(s). Requires 'state' input.
#' @param bb        \code{logical}. If \code{TRUE} then the bounding geometry of state/county is returned,  default is \code{FALSE} and returns fiat geometries
#' @return a \code{SpatialPolygons} object projected to \emph{EPSG:4269}.
#' @export
#' @seealso \code{\link{getClip}}
#' @seealso \code{\link{getAOI}}
#' @noRd
#' @examples
#' \dontrun{
#' # Get Single State
#'     getFiat(state = "CA")
#'
#' # Get Multi-state
#'     getFiat(state = c("CA","Utah","Nevada"))
#'
#' # Get County
#'     getFiat(state = "CA", county = "San Luis Obispo")
#'
#' # Get Muli-county
#'    getFiat(state = "CA", county = c("San Luis Obispo", "Santa Barbara", "Ventura"))
#'}
#'
#' @author Mike Johnson


getFiat <- function(state = NULL, county = NULL, bb = FALSE) {

  states = AOI::states

  for(i in 1:length(state)){
    if(nchar(state[i]) == 2){state[i] = states$state_name[which(states$state_abbr == state[i])]}
  }

  state_map = states[tolower(states$state_name) %in% tolower(state),]

  if(is.null(county)) {
    map = state_map
    rm(states)

  } else {

    counties = AOI::counties
    county_map = counties[tolower(counties$state_name) %in% tolower(state),]

    if(any(county == 'all')) {
      map = county_map
      rm(counties)
    } else {

    county = simpleCap(county)
    check = county %in% county_map$name

    if(!all(check)) {
      bad_counties  = county[which(!(check))]
      stop(paste(bad_counties, collapse = ", "), " not a valid county in ", state, ".")
    }

    map = county_map[county_map$name %in% county,]
    rm(counties)
    }
  }

  if(bb){map = getBoundingBox(map)}

  return(map)

}



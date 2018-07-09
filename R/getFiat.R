#' Get County and State SpatialPolygon(s)
#'
#' @details
#' \code{getFiat} returns a \code{SpatialPolygons} object for a defiend state and/or county.
#' Boundaries come from the 2017 US Census TIGER Dataset and are projected to \emph{EPSG:4269}.
#'
#' @param state     character. Full name or two character abbriviation. Not case senstive
#' @param county    character. Provide county name(s). Requires 'state' input.
#'
#' @return a \code{SpatialPolygons} object projected to \emph{EPSG:4269}.
#' @export
#' @seealso \code{\link{getClip}}
#' @seealso \code{\link{getAOI}}
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


getFiat <- function(state = NULL, county = NULL) {

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

    county = simpleCap(county)
    check = county %in% county_map$name

    if(!all(check)) {
      bad_counties  = county[which(!(check))]
      stop(paste(bad_counties, collapse = ", "), " not a valid county in ", state, ".")
    }

    map = county_map[county_map$name %in% county,]
    rm(counties)

  }

  return(map)

}



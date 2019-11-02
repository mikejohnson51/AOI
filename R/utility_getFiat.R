#' @title Get State of County Spatial Boundary
#' @details \code{getFiat} returns a \code{SpatialPolygons} object for a defiend state and/or county.
#' Boundaries come from the 2017 US Census TIGER Dataset and are projected to \emph{EPSG:4269}.
#' @param country   \code{character}. Full name, ISO 3166-1 2 or 3 digit code. Not case senstive
#' @param state     \code{character}. Full name or two character abbriviation. Not case senstive
#' @param county    \code{character}. Provide county name(s). Requires 'state' input.
#' @param bb        \code{logical}. If \code{TRUE} then the bounding geometry of state/county is returned,  default is \code{FALSE} and returns fiat geometries
#' @return a \code{SpatialPolygons} object projected to \emph{EPSG:4269}.
#' @export
#' @seealso \code{\link{getClip}}
#' @seealso \code{\link{getAOI}}
#' @keywords internal
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

getFiat <- function(country = NULL, state = NULL, county = NULL) {

  map1 <- map2 <- map3 <- NULL

  if(!is.null(country)){

      world = AOI::countries

      calls = c()

  for(i in seq_along(country)){

      if(nchar(country[i]) == 2){
        calls = append(calls, world$name[tolower(world$iso_a2) %in% tolower(country[i])])
      }

      if(nchar(country[i]) == 3){
        calls = append(calls, world$name[tolower(world$iso_a3) %in% tolower(country[i])])
      }

      if(nchar(country[i]) > 3){
        calls = append(calls, world$name[tolower(world$name) %in% tolower(country[i])])
      }

      if(length(calls) == 0){ stop('no country found')}

  }

      map1  = world[tolower(world$name) %in% tolower(calls),]
  }

  if(!is.null(state)){

    states = AOI::states
    #+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs

    for(i in 1:length(state)){
      if(nchar(state[i]) == 2){state[i] = states$state_name[which(tolower(states$state_abbr) == tolower(state[i]))]}
    }

    if(any(tolower(state) == 'all')){
      map2 = states
    } else if(any(tolower(state) == 'conus')){
      map2 = states[!(tolower(states$state_name) %in% c('alaska', "puerto rico", 'hawaii')),]
    } else {
      map2 = states[tolower(states$state_name) %in% tolower(state),]
    }

    if(!is.null(county)) {

      map2 = NULL
      counties = AOI::counties
      county_map = counties[tolower(counties$state_name) %in% tolower(state),]

      if(any(county == 'all')) {
        map3 = county_map
      } else {

      check = tolower(county) %in% tolower(county_map$name)

      if(!all(check)) {
        bad_counties  = county[which(!(check))]
        stop(paste(bad_counties, collapse = ", "), " not a valid county in ", state, ".")
      }

      map3 = county_map[tolower(county_map$name) %in% tolower(county),]

      }
    }
  }

  map  = tryCatch({
    rbind(map1, map2, map3)
  }, error = function(e) {
    if(!is.null(map1)){ map1 = dplyr::mutate(map1, 'NAME' = map1$name) %>% dplyr::select('NAME') }
    if(!is.null(map2)){ map2 = dplyr::mutate(map2, 'NAME' = map2$state_name) %>% dplyr::select('NAME')  }
    if(!is.null(map3)){ map3 = dplyr::mutate(map3, 'NAME' = map3$name) %>% dplyr::select('NAME')}
    rbind(map1, map2, map3)
  })

  return(map)

}



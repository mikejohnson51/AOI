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

  state.abb  = states$state_abbr
  state.name = states$state_name

  map1 <- map2 <- map3 <- NULL

  find = function(x, vec, full){
    full[tolower(vec) %in% tolower(x)]
  }

  if(!is.null(country)){

      country <- unlist(c(
        sapply(country, find, vec = countries$name,   full = countries$name),
        sapply(country, find, vec = countries$iso_a2, full = countries$name),
        sapply(country, find, vec = countries$iso_a3, full = countries$name)
      ))

      if(length(country) == 0){ stop('no country found')}

      map1  <- countries[countries$name %in% country,]
  }

  if(!is.null(state)){

    if(any(tolower(state) == 'conus')) {
      state = states$state_name[!states$state_name %in% c("Alaska", "Puerto Rico", "Hawaii")]
    }

    if(any(tolower(state) == 'all')) { state = states$state_name }

    state = unlist(c(
      sapply(state, find, vec = states$state_abbr, full = states$state_name),
      sapply(state, find, vec = states$state_name, full = states$state_name)
    ))

    map2 <- states[states$state_name %in% state,]
  }

    if(!is.null(county)) {
      map2 <- NULL
      county_map <- counties[tolower(counties$state_name) %in% tolower(state),]

      if(any(county == 'all')) {
        map3 <- county_map
      } else {
        check <- (tolower(county) %in% tolower(county_map$name))
      if(!all(check)) {
        bad_counties  = county[which(!(check))]
        stop(paste(bad_counties, collapse = ", "),
             " not a valid county in ", state, ".")
      }

      map3 = county_map[tolower(county_map$name) %in% tolower(county),]
      }
  }

  map  = tryCatch({
    rbind(map1, map2, map3)
  }, error = function(e) {
    if(!is.null(map1)){ map1 = mutate(map1, 'NAME' = map1$name) %>% select('NAME')}
    if(!is.null(map2)){ map2 = mutate(map2, 'NAME' = map2$state_name) %>% select('NAME')}
    if(!is.null(map3)){ map3 = mutate(map3, 'NAME' = map3$name)  %>% select('NAME')}
    rbind(map1, map2, map3)
  })

  return(map)

}


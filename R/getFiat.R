#' @title Get State of County Spatial Boundary
#' @details
#' \code{getFiat} returns a \code{SpatialPolygons} object
#' for a defiend state and/or county. Boundaries come from
#' the 2017 US Census TIGER Dataset and are projected to
#' \emph{EPSG:4269}.
#' @param country \code{character}. Full name, ISO 3166-1 2 or 3 digit code.
#'                Not case senstive
#' @param state \code{character}. Full name or two character abbriviation.
#'              Not case senstive
#' @param county \code{character}. Provide county name(s).
#'               Requires 'state' input.
#' @param bb \code{logical}. If \code{TRUE} then the bounding geometry of
#'           state/county is returned,  default is \code{FALSE} and returns
#'           fiat geometries
#' @return a \code{SpatialPolygons} object projected to \emph{EPSG:4269}.
#' @export
#' @keywords internal
#' @examples
#' \dontrun{
#' # Get Single State
#' getFiat(state = "CA")
#'
#' # Get Multi-state
#' getFiat(state = c("CA", "Utah", "Nevada"))
#'
#' # Get County
#' getFiat(state = "CA", county = "San Luis Obispo")
#'
#' # Get Muli-county
#' getFiat(state = "CA", county = c("San Luis Obispo", "Santa Barbara", "Ventura"))
#' }
#'
#' @author Mike Johnson

getFiat <- function(country = NULL, state = NULL, county = NULL, fip = NULL) {
  map0 <- map1 <- map2 <- map3 <- map4 <- NULL

  find <- function(x, vec, full) { full[tolower(vec) %in% tolower(x)] }

  if (!is.null(country)) {
    countries <- rnaturalearth::ne_countries(returnclass = "sf") %>%
      st_transform(4269)

    region <- tolower(country)
    region <- gsub("south", "southern", region)
    region <- gsub("australia", "oceania", region)
    region <- gsub("north", "northern", region)
    region <- gsub("east", "eastern", region)
    region <- gsub("west", "western", region)

    region <- unlist(c(
      sapply(region, find, vec = countries$subregion, full = countries$name),
      sapply(region, find, vec = countries$continent, full = countries$name)
    ))

    map0 <- countries[countries$name %in% region, ]

    country <- unlist(c(
      sapply(country, find, vec = countries$name, full = countries$name),
      sapply(country, find, vec = countries$iso_a2, full = countries$name),
      sapply(country, find, vec = countries$iso_a3, full = countries$name)
    ))

    map1 <- countries[countries$name %in% country, ]
    if (all(nrow(map0) == 0, nrow(map1) == 0)) {
      stop("No country found.")
    }
  }

  if (!is.null(state)) {
    meta <- list_states()

    states <- USAboundaries::us_states() %>%
      merge(data.frame(
        state_abbr = meta$abb,
        region = as.character(meta$region),
        stringsAsFactors = F
      ),
      all.x = TRUE
      ) %>%
      st_transform(4269)

    state1 <- state2 <- state3 <- NULL

    if (any(tolower(state) %in% tolower(states$region))) {
      state1 <- states$state_name[tolower(states$region) %in% tolower(state)]
    }

    if (any(tolower(state) == "conus")) {
      state2 <- states$state_name[!states$state_name %in% c("Alaska", "Puerto Rico", "Hawaii")]
    }

    if (any(tolower(state) == "all")) {
      state3 <- states$state_name
    }

    state <- c(state, state1, state2, state3)

    state <- unlist(c(
      sapply(state, find, vec = states$state_abbr, full = states$state_name),
      sapply(state, find, vec = states$state_name, full = states$state_name)
    ))

    map2 <- states[states$state_name %in% unique(state), ]
  }

  if (!is.null(county)) {
    counties <- USAboundaries::us_counties() %>%
                sf::st_transform(4269)

    map2 <- NULL

    county_map <- counties[tolower(counties$state_name) %in% tolower(state), ]

    if (any(county == "all")) {
      map3 <- county_map
    } else {
      check <- (tolower(county) %in% tolower(county_map$name))
      if (!all(check)) {
        bad_counties <- county[which(!(check))]
        stop(
          paste(bad_counties, collapse = ", "),
          " not a valid county in ", state, "."
        )
      }

      map3 <- county_map[tolower(county_map$name) %in% tolower(county), ]
    }
  }

  if(!is.null(fip)){
    if(!nchar(fip) %in% c(2,5)){
      stop("FIP codes must be of length 2,3 or 5")
    }

    if(nchar(fip) == 2){
      map4 <- USAboundaries::us_states()
      map4 <- map4[map4$statefp == fip,] %>%
        sf::st_transform(4269)
    } else {
      map4 <- USAboundaries::us_counties()
      map4 <- map4[map4$geoid == fip,] %>%
        sf::st_transform(4269)
    }


  }



  map <- tryCatch(
    {
      rbind(map0, map1, map2, map3, map4)
    },
    error = function(e) {
      if (!is.null(map0)) {
        map0 <- dplyr::select(map0, "NAME" = map0$name)
      }
      if (!is.null(map1)) {
        map1 <- dplyr::select(map1, "NAME" = map1$name)
      }
      if (!is.null(map2)) {
        map2 <- dplyr::select(map2, "NAME" = map2$state_name)
      }
      if (!is.null(map3)) {
        map3 <- dplyr::select(map3, "NAME" = map3$name)
      }
      if (!is.null(map3)) {
        map3 <- dplyr::select(map3, "NAME" = map4$name)
      }
      rbind(map1, map2, map3, map4)
    }
  )

  return(map)
}

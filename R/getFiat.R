.find <- function(x, vec, full) { full[tolower(vec) %in% tolower(x)] }

#' @title Get State of County Spatial Boundary
#' @details
#' \code{getFiat} returns a \code{SpatialPolygons} object
#' for a defiend state and/or county. Boundaries come from
#' the 2017 US Census TIGER Dataset and are projected to
#' \emph{EPSG:4269}.
#' @param country \code{character}. Full name, ISO 3166-1 2 or 3 digit code.
#'                Not case senstive
#' @param state \code{character}. Full name or two character abbreviation.
#'              Not case sensitive
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
#' @importFrom rnaturalearth ne_countries
#' @importFrom fipio fips_metadata

getFiat <- function(country = NULL, state = NULL, county = NULL, fip = NULL) {

  map0 <- map1 <- map2  <- map3 <-  NULL

  if (!is.null(country)) {
    countries <- rnaturalearth::ne_countries(returnclass = "sf")

    region1 <- tolower(country)
    region2 <- gsub("south", "southern", region)
    region2 <- gsub("australia", "oceania", region)
    region2 <- gsub("north", "northern", region)
    region2 <- gsub("east", "eastern", region)
    region2 <- gsub("west", "western", region)

    region <- unique(unlist(c(
      sapply(c(region1, region2), .find, vec = countries$subregion, full = countries$name),
      sapply(c(region1, region2), .find, vec = countries$continent, full = countries$name)
    )))

    map0 <- countries[countries$name %in% region, ]

    country <- unlist(c(
      sapply(country, .find, vec = countries$name,   full = countries$name),
      sapply(country, .find, vec = countries$iso_a2, full = countries$name),
      sapply(country, .find, vec = countries$iso_a3, full = countries$name)
    ))

    map1 <- countries[countries$name %in% country, ]

    if (all(nrow(map0) == 0, nrow(map1) == 0)) {
      stop("No country found.")
    }
  }

  if (!is.null(state)) {

    ret = tryCatch({
      fip_meta(state = state, county = county)
      },
      error = function(e){ NULL })

    ret = ret[!sf::st_is_empty(ret),]

    if(is.null(ret) | nrow(ret) == 0 ){
      ret = list_states()
      ret = ret[tolower(ret$region) %in% tolower(state),]
      ret = merge(
        fip_meta(state = ret$state_abbr, county = county),
        list_states(),
        all.x = TRUE)
    }

    if(nrow(ret) == 0 ){ stop('State, county pair(s) not found', call. = FALSE) }

    map2 <- ret

  }

  if(!is.null(fip)){
    if(!nchar(fip) %in% c(2,5)){
      stop("FIP codes must be of length 2 or 5")
    } else {
      map3 <-  fipio::fips_metadata(fip, geometry = TRUE)
    }
  }

  ll = list(map0, map1, map2, map3)

  if(sum(unlist(lapply(ll, nrow)) > 0) > 1){
    ll = lapply(1:length(ll), function(x){ ll[[x]][, c('name')]})
  }

  return(do.call(rbind, ll))
}

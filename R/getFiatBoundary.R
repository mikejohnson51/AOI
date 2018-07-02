#' Get County and State SpatialPolygon(s)
#'
#' @details
#' \code{getFiatBoundary} gets a \code{SpatialPolygon} for a defiend state and/or county or those intersecting a clip_unit.
#' Fiat boundaries come from the 2017 US Census Bureau 2017 TIGER Dataset.
#'
#' All HydroData outputs are projected to \emph{'+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0+no_defs'}
#'
#' @param state     character. Full name or two character abbriviation. Not case senstive
#' @param county    character. Provide county name(s). Requires 'state' input.
#' @param clip_unit SpatialObject* or list. For details see \code{?getClipUnit}
#'
#' @return \code{getFiatBoundary} returns a \code{SpatialPolygon} Object
#' @export
#' @seealso \itemize{
#'          \item \code{\link{getClipUnit}}
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
#' @author
#' Mike Johnson
#'



getFiatBoundary <- function(state = NULL, county = NULL, clip_unit = NULL) {

  USAboundaries_version <- "0.3.1"

  install_USAboundariesData <- function() {
    install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source")
  }

  if (!requireNamespace("USAboundariesData", quietly = TRUE)) {
    message("Installing USAboundariesData package.")
    install_USAboundariesData()
  } else if (utils::packageVersion("USAboundariesData") < USAboundaries_version) {
    message("Updating the USAboundariesData package.")
    install_USAboundariesData()
  }

  if(!is.null(clip_unit)){
    A = getAOI(state = NULL, county = NULL, clip_unit = clip_unit)

    s = USAboundaries::us_states(map_date = NULL, resolution = "high", states = state)
    states = sf::as_Spatial(sf::st_geometry(s), IDs = as.character(1:nrow(s)))
    df = s
    df$geometry <- NULL
    df <- as.data.frame(df)
    row.names(df) = NULL
    states <- sp::SpatialPolygonsDataFrame(states, data = df) %>% spTransform(HydroDataProj)

    states = states[A, ]

    c = USAboundaries::us_counties(map_date = NULL, resolution = "high", states = states$name)
    counties = sf::as_Spatial(sf::st_geometry(c), IDs = as.character(1:nrow(c)))
    df = c
    df$geometry <- NULL
    df <- as.data.frame(df)
    row.names(df) = NULL
    counties <- sp::SpatialPolygonsDataFrame(counties, data = df) %>% spTransform(HydroDataProj)

    map = counties[A, ]

  } else {

    c = USAboundaries::us_counties(map_date = NULL, resolution = "high", states = state)
    counties = sf::as_Spatial(sf::st_geometry(c), IDs = as.character(1:nrow(c)))
    df = c
    df$geometry <- NULL
    df <- as.data.frame(df)
    row.names(df) = NULL
    counties <- sp::SpatialPolygonsDataFrame(counties, data = df) %>% spTransform(HydroDataProj)

    map <- sp::SpatialPolygonsDataFrame(counties, data = df) %>% spTransform(HydroDataProj)

    if(!is.null(county)){
      county.map <- vector(mode = "character")
      for (i in 1:length(county)) { county.map <- append(county.map, simpleCap(tolower(county[i]))) }

      bad.counties  = setdiff(county.map, map$name)

      if(nchar(state) == 2){state = setNames(state.name, state.abb)[toupper(state)][1]}

      if(length(bad.counties) > 0){stop(paste(bad.counties, collapse = ", "), " not a valid county in ", state, ".")}

      map <- map[map$name %in% county.map, ]
    }
  }

  return(map)

}

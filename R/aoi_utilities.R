#' @title Buffer AOI
#' @description Add or subtract a uniform distance to/from a
#'              spatial object in either miles or kilometers.
#' @param AOI a spatial, raster or simple features object
#' @param d \code{numeric}.The distance by which to modify each edge
#' @param km \code{logical}. If \code{TRUE} distances are in kilometers,
#'           default is \code{FALSE} with distances in miles
#' @return a spatial geometry of the same class as the input AOI
#'        (if Raster sp returned)
#' @export
#' @examples
#' \dontrun{
#' # get an AOI of 'Garden of the Gods' and add a 2 mile buffer
#' AOI <- aoi_get(x = "Garden of the Gods") %>% modify(2)
#'
#' # get an AOI of 'Garden of the Gods' and add a 2 kilometer buffer
#' getAOI("Garden of the Gods") %>% modify(2, km = TRUE)
#'
#' # get and AOI for Colorado Springs and subtract 3 miles
#' getAOI("Colorado Springs") %>% modify(-3)
#' }
#' @importFrom sf st_crs st_transform st_buffer

aoi_buffer <- function(AOI, d, km = FALSE) {
  AOI <- make_sf(AOI)

  crs <- sf::st_crs(AOI)

  if (km) {
    u <- d * 3280.84
  } # kilometers to feet
  if (!km) {
    u <- d * 5280
  } # miles to feet

  sf::st_transform(AOI, 6829)  |>
    sf::st_buffer(
      dist = u,
      joinStyle = "MITRE",
      endCapStyle = "SQUARE",
      mitreLimit = 2
    )  |>
    sf::st_transform(crs)
}

#' @title Is Inside
#' @description A check to see if one object is inside another
#' @param obj object 1
#' @param AOI object 2
#' @param total boolean.
#'              If \code{TRUE} then check if obj is completely
#'              inside the AOI (and vice versa: order doesn't matter).
#'              If \code{FALSE}, then check if at least part
#'              of obj is in the AOI.
#' @return boolean value
#' @export
#' @importFrom sf st_intersects st_intersection st_transform st_crs

aoi_inside <- function(AOI, obj, total = TRUE) {

  AOI <- make_sf(AOI)

  obj <- st_transform(make_sf(obj), st_crs(AOI))

  int <- suppressMessages(st_intersects(obj, AOI))

  if (!apply(int, 1, any)) {
    return(FALSE)
  } else {
    x <- suppressWarnings(
      suppressMessages(sf::st_intersection(obj, AOI))
    )

    inside <- any(x$geometry == AOI$geometry, x$geometry == obj$geometry)

    if (total) {
      return(inside)
    } else {
      return(TRUE)
    }
  }
}

#' @title Convert raster and sp objects to sf
#' @description Convert raster and sp objects to sf
#' @param x any spatial object
#' @return an sf object
#' @keywords internal
#' @importFrom sf st_as_sf

make_sf <- function(x) {
  if (inherits(x, "Raster")) {
    x <- bbox_get(x)
  } else if (inherits(x, "Spatial")) {
    x <- sf::st_as_sf(x)
  } else if (inherits(x, "data.frame")) {
    x <- sf::st_as_sf(x)
  } else {
    x <- NULL
  }

  x
}

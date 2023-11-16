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
  if (inherits(x, "SpatRaster")) {
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

rename_geometry = function(g, name) {
  current = attr(g, "sf_column")
  names(g)[names(g) == current] = name
  attr(g, "sf_column") <- name
  g
}


#' Returns a data.frame of valid states with abbreviations and regions
#'
#' @return data.frame of states with abbreviation and region
#' @export
#' @examples
#' \dontrun{
#' list_states()
#' }

list_states <- function() {
  return(data.frame(
    state_abbr   = datasets::state.abb,
    name         = datasets::state.name,
    region       = datasets::state.region
  ))
}

#' Returns a sf data.frame of fipio data
#' @param state State names, state abbreviations, or one of the following: "all", "conus", "territories"
#' @param county County names or "all"
#' @return sf data.frame
#' @export
#' @examples
#' \dontrun{
#' fip_meta()
#' }
#' @importFrom sf st_as_sf
#' @importFrom fipio as_fips fips_metadata
fip_meta <- function(state, county = NULL) {

  fipio::as_fips(county = county, state = state) %>%
    fipio::fips_metadata(geometry = TRUE) %>%
    st_as_sf()
}


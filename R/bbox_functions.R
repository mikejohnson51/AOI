#' @title Get Spatial Bounding Box
#' @description
#' Get spatial (sf) representation of bounding box of an input feature type.
#' Input can be data.frame, numeric, character, or spatial (sp/sf/raster).
#' If numeric or character order of inputs should be (xmin, xmax, ymin, ymax)
#' @param x input feature
#' @return a sf polygon
#' @export

bbox_get <- function(x) {
  if (methods::is(x, "character")) {
    x <- strsplit(x, ",")[[1]] %>%
      as.numeric()
    x <- sf::st_bbox(
      c(xmin = x[1], xmax = x[2], ymin = x[3], ymax = x[4]),
      crs = sf::st_crs(4326)
    )
  } else if (methods::is(x, "numeric")) {
    x <- sf::st_bbox(
      c(xmin = x[1], xmax = x[2], ymin = x[3], ymax = x[4]),
      crs = sf::st_crs(4326)
    )
  } else {
    x <- suppressWarnings({
      sf::st_bbox(x, crs = sf::st_crs(x))
    })
  }

  sf::st_sf(sf::st_as_sfc(x))
}

#' @title Return bounding box coordinates of a spatial (sp/sf/raster) object
#' @description This function provides a simple wrapper around sf::st_bbox
#'              that instead returns a named data.frame containing
#'              (xmin, ymin, xmax, ymax)
#' @param x a spatial object (sp/sf/raster)
#' @return a data.frame
#' @export

bbox_coords <- function(x) {
  bb <- suppressWarnings({ sf::st_bbox(x) })
  # df <- data.frame(
  #   xmin = bb[1], ymin = bb[2],
  #   xmax = bb[3], ymax = bb[4],
  #   row.names = NULL
  # )
  return(bb)
}

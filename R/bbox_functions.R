#' @title Get Spatial Bounding Box
#' @description
#' Get spatial (sf) representation of bounding box of an input feature type.
#' Input can be data.frame, numeric, character, or spatial (sp/sf/raster).
#' If numeric or character order of inputs should be (xmin, xmax, ymin, ymax)
#' @param x input feature
#' @return a sf polygon
#' @export
#' @importFrom sf st_bbox st_crs st_as_sfc st_sf

bbox_get <- function(x) {
  if (inherits(x, "character")) {
    x <- as.numeric(strsplit(x, ",")[[1]])

    x <- sf::st_bbox(
      c(xmin = x[1], xmax = x[2], ymin = x[3], ymax = x[4]),
      crs = sf::st_crs(4326)
    )
  } else if (inherits(x, "numeric")) {
    x <- sf::st_bbox(
      c(xmin = x[1], xmax = x[2], ymin = x[3], ymax = x[4]),
      crs = sf::st_crs(4326)
    )
  } else {
    x <- suppressWarnings({
      sf::st_bbox(x, crs = sf::st_crs(x))
    })
  }

  sf::st_as_sf(sf::st_as_sfc(x)) %>%
    rename_geometry("geometry")
}

#' @title Return bounding box coordinates of a spatial (sp/sf/raster) object
#' @description This function provides a simple wrapper around sf::st_bbox
#'              that instead returns a named data.frame containing
#'              (xmin, ymin, xmax, ymax)
#' @param x a spatial object (sp/sf/raster)
#' @return a data.frame
#' @export
#' @importFrom sf st_bbox

bbox_coords <- function(x) {

  return(suppressWarnings({ st_bbox(x) }))
}

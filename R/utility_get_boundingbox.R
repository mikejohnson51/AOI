#' Get Bounding box
#'
#' @description A function to define a minimum bounding box for a set of points
#'
#' @param x a \code{data.frame} with a lat and long column, a Raster or a Spatial Object
#'
#' @return a \code{SpatialPolygon} bounding box of input points \code{x}
#'
#' @family HydroData 'utility' function

getBoundingBox = function(x) {

  if(checkClass(x, "Spatial")) {
    x = data.frame(t(x@bbox))
    row.names(x) = NULL
    colnames(x) = c("long", "lat")
  }

  if(checkClass(x, "Raster")) {
    x = x@extent
    x = data.frame(long = c(x@xmin, x@xmax), lat = c(x@ymin, x@ymax))
  }

  if(checkClass(x, "sf")) {
    x = sf::st_bbox(x)
    x = data.frame(long = c(x[1], x[3]), lat = c(x[2],x[4]))
  }

  coords = matrix(
    c(
      min(x$long),
      min(x$lat),
      min(x$long),
      max(x$lat),
      max(x$long),
      max(x$lat),
      max(x$long),
      min(x$lat),
      min(x$long),
      min(x$lat)
    ),
    ncol = 2,
    byrow = TRUE
  )

  bb = sp::Polygon(coords)
  bb = sp::SpatialPolygons(list(Polygons(list(bb), ID = "AOI")), proj4string = AOI::aoiProj)

  return(bb)
}


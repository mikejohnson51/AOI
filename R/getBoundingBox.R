#' @title Get mimimum bounding box of spatial features
#' @description Returns a minimum bounding box for a spatial, raster or sf object(s)
#' @param x a \code{data.frame} with a lat and long column, a raster, sf, or spatial object
#' @param sf \code{logical}. If TRUE object returned is of class \code{sf}, default is FALSE and returns \code{SpatialPolygons}
#' Default is \code{FALSE} and returns class SpatialPolygon
#' @examples
#' \dontrun{
#'   ## Find the 10 closest Airports to UCSB
#'      ap = geocode("UCSB") %>% HydroData::findNearestAirports(n =10)
#'      AOI = ap$ap %>% getBoundingBox()
#'
#'   ## Get bounding box of raster object
#'      AOI = getBoundingBox(r)
#' }
#' @export
#' @author Mike Johnson

getBoundingBox = function(x, sf = FALSE) {

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
    c(min(x$long), min(x$lat),
      min(x$long), max(x$lat),
      max(x$long), max(x$lat),
      max(x$long), min(x$lat),
      min(x$long), min(x$lat)
    ), ncol = 2, byrow = TRUE )

  poly = sf::st_sfc(sf::st_polygon(list(coords)), crs = 4269)

  if(!sf){ poly = sf::as_Spatial(poly)}

  return(poly)
}


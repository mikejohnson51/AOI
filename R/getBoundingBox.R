#' @title Get mimimum bounding box of spatial features
#' @description Returns a minimum bounding box for a spatial, raster or sf object(s)
#' @param x a \code{data.frame} with a lat and lon column, a raster, sf, or spatial object
#' @examples
#' \dontrun{
#'   ## Find the 10 closest Airports to UCSB
#'      ap = geocode("UCSB") %>% HydroData::findNearestAirports(n =10)
#'      AOI = ap$ap %>% getBoundingBox()
#'
#'   ## Get bounding box of California
#'      AOI = getAOI(state = 'CA') %>% getBoundingBox()
#'
#'   ## Get bounding box of raster object
#'      AOI = getBoundingBox(r)
#' }
#' @export
#' @author Mike Johnson

getBoundingBox = function(x) {

  if(checkClass(x, "Spatial")) {
    crs = x@proj4string
    x   = st_as_sf(x)
    }

  if(checkClass(x, "Raster")) {
    crs = x@crs
    x   = x@extent
    x   = data.frame(long = c(x@xmin, x@xmax), lat = c(x@ymin, x@ymax))
  }

  if(checkClass(x, "sf")) {
    crs = sf::st_crs(x)
    x   = sf::st_bbox(x)
    x   = data.frame(long = c(x[1], x[3]), lat = c(x[2],x[4]))
  }

  return(make_polygon(max(x$lat), max(x$lon), min(x$lat), min(x$lon), crs = crs))

}

# r@extent
# x = r

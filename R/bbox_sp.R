#' @title Convert bounding box strings to spatail geometries
#' @description Convert a vector, data.frame, bb object, or raster to a spatial (sp/sf) geometry
#' @param s a comma seperated \code{character}  string, \code{numeric} vector, or data.frame in the order ("xmin","xmax", "ymin", "ymax"). \code{Raster} objects are also accepted.
#' @return a spatial (sp/sf) geometry projected to \emph{EPSG:4269}
#' @author Mike Johnson
#' @seealso \code{\link{bbox_st}}
#' @examples
#' \dontrun{
#'
#' ## SpatialPolygon from string
#'    bbox = bbox_sp("37,36,-119,-118")
#'
#' ## SpatialPolygon from vector
#'    bbox = c(37,38,-119,-118) %>% bbox_sp()
#'
#' ## Simple Feature Polygon from data.frame
#'    bbox = data.frame(xmin = 37, xmax = 38, ymin = -119, ymax = -118) %>% bbox_sp(sf = T)
#'
#' ## SpatialPolygon from Reverse Geocoding results
#'    bbox = revgeocode("Santa Barbara")$bb %>% bbox_sp()
#'
#' ## String to Geometry to String (full circle)
#'     bbox = c(37,38,-119,-118) %>% bbox_sp() %>% bbox_st()
#'
#' ## Raster to simple features polygon
#'    raster %>% bbox_sp(sf = TRUE)
#' }
#' @export

bbox_sp = function(s){

  if(checkClass(s, "numeric")){
    b = as.data.frame(t(s), stringsAsFactors = FALSE)
    names(b) = c("xmin","xmax", "ymin", "ymax")
  } else if (checkClass(s, 'Raster')){
    b = getBoundingBox(s) %>% bbox_st()
  } else {
    tmp = as.numeric(unlist(strsplit(s, ",")))
    b = as.data.frame(t(tmp), stringsAsFactors = FALSE)
    names(b) = c("xmin","xmax", "ymin", "ymax")
  }

  coords = matrix(c(b$xmin, b$ymin,
                    b$xmin, b$ymax,
                    b$xmax, b$ymax,
                    b$xmax, b$ymin,
                    b$xmin, b$ymin),
                    ncol = 2, byrow = TRUE)

  poly = sf::st_sfc(sf::st_polygon(list(coords)), crs = 4269) %>% sf::st_sf()

  return(poly)

}


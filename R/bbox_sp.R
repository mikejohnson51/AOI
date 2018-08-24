#' @title Convert bounding box string to geometry
#' @description Convert a vector, dataframe, bb, or raster object to a spatial geometry
#' @param bbox_st a \code{character} comma seperated string,\code{numeric} vector, or data.frame in the order ("xmin","xmax", "ymin", "ymax"). \code{Raster} objects are also accepted.
#' @param sf \code{logical}. If TRUE object returned is of class \code{sf}, default is FALSE and returns \code{SpatialPolygons}
#' @return a bounding box geometry
#' @author Mike Johnson
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
#' ## Raster to sf
#'    raster %>% bbox_sp(sf = TRUE)
#' }
#' @export

bbox_sp = function(bbox_st, sf = FALSE){

  if(checkClass(bbox_st, "numeric")){

    b = as.data.frame(t(bbox_st), stringsAsFactors = FALSE)
    names(b) = c("xmin","xmax", "ymin", "ymax")

  } else if(checkClass(bbox_st, 'bb')){

    b = bbox_st

  } else if (checkClass(bbox_st, 'Raster')){

    b = getBoundingBox(bbox_st) %>% bbox_st()

  } else {

    tmp = as.numeric(unlist(strsplit(bbox_st, ",")))
    b = as.data.frame(t(tmp), stringsAsFactors = FALSE)
    names(b) = c("xmin","xmax", "ymin", "ymax")
  }

  coords = matrix(c(b$xmin, b$ymin,
                    b$xmin, b$ymax,
                    b$xmax, b$ymax,
                    b$xmax, b$ymin,
                    b$xmin, b$ymin),
                    ncol = 2, byrow = TRUE)

  poly = sf::st_sfc(sf::st_polygon(list(coords)), crs = 4269)

  if(!sf){ poly = sf::as_Spatial(poly)}

  return(poly)

}


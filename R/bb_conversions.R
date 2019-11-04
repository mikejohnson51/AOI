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

  flip = function(x){
    data.frame(t(x), stringsAsFactors = FALSE) %>%
    setNames(c("xmin","xmax", "ymin", "ymax"))
  }

  b = if(checkClass(s, "numeric")){
    flip(s)
  } else if (checkClass(s, 'Raster')){
    getBoundingBox(s) %>% bbox_st()
  } else {
    flip(as.numeric(unlist(strsplit(s, ","))))
  }

  return(make_polygon(b$ymax, b$xmax, b$ymin, b$xmin))

}

#' @title Convert spatial geometries to a data.frame of coordinates
#' @description Convert a spatial (sp/sf) object to a data.frame of ("xmin", "xmax", "ymin", "ymax")
#' @param AOI any spatial object (\code{raster}, \code{sf}, \code{sp}). Can be piped (\%>\%) from \code{\link{getAOI}}
#' @return a data.frame containing xmin. xmax, ymin, ymax coordinates
#' @export
#' @seealso \code{\link{bbox_sp}}
#' @examples
#' \dontrun{
#' ## Get a bounding box data.frame for AOI
#'    AOI = getAOI(list("UCSB", 10, 10)) %>% bbox_st()
#'
#' >   xmin     xmax    ymin     ymax
#' >  -119.9337 -119.758 34.34213 34.48706
#' }


bbox_st = function(AOI){
  bb = st_bbox(AOI)
  df = data.frame(xmin = bb[1], ymin = bb[2],
                  xmax = bb[3], ymax = bb[4],
                  row.names = NULL )
  return(df)
}



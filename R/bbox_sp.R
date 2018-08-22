#' @title Convert bounding box string to geometry
#' @description Convert a vector, dataframe, or bb object to a \code{SpatialPolygon}
#' @param bbox_st a bounding box string or vector in the order ("xmin","xmax", "ymin", "ymax")
#' @param sf logical. Should returned feature be of class sf (default = FALSE)
#' @return a bounding box geometry
#' @author Mike Johnson
#' @examples
#' \dontrun{
#' CO = getAOI(state = 'CO') %>% bbox_st()
#' CO.1 = CO %>% bbox_sp()
#' }
#' @export

bbox_sp = function(bbox_st, sf = FALSE){

  if(checkClass(bbox_st, "numeric")){

    b = as.data.frame(t(bbox_st), stringsAsFactors = FALSE)
    names(b) = c("xmin","xmax", "ymin", "ymax")

  } else if(checkClass(bbox_st, 'bb')){

    b = bbox_st

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






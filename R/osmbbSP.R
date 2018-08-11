#' @title  OSM bounding Box to Geometry
#' @description Convert a OSM returned bounding box to a \code{SpatialPolygon}
#' @param osm_bb an osm bounding box
#' @return a \code{SpatialPolygon}
#' @author Mike Johnson
#' @export

osmbb_sp = function(osm_bb){

  tmp = as.numeric(unlist(strsplit(osm_bb, ",")))
  b = as.data.frame(t(tmp), stringsAsFactors = FALSE)
  names(b) = c("ymax","ymin", "xmin", "xmax")

  coords = matrix(c(b$xmin, b$ymin,
                    b$xmin, b$ymax,
                    b$xmax, b$ymax,
                    b$xmax, b$ymin,
                    b$xmin, b$ymin),
                  ncol = 2, byrow = TRUE)

  P1 = sp::Polygon(coords)
  Ps1 = sp::SpatialPolygons(list(sp::Polygons(list(P1), ID = "bb")), proj4string=AOI::aoiProj)

  return(Ps1)

}

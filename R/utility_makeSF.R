#' @title Convert raster and sp objects to sf
#' @description Convert raster and sp objects to sf
#' @param x any spatial object
#' @return an sf object
#' @export
#' @author Mike Johnson

make_sf = function(x){
  if (checkClass(x, "raster")) {AOI = getBoundingBox(x) }
  if (checkClass(x, "sp")) { AOI = sf::st_as_sf(x) }
  if (checkClass(x, "sf")) { AOI = sf::st_as_sf(x) }
  return(AOI)
}

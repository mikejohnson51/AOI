#' @title Modify AOI
#' @description Add or subtract a uniform distance to/from a spatial object in either miles or kilometers.
#' @param AOI a spatial, raster or simple features object
#' @param d \code{numeric}.The distance by which to modify each edge
#' @param km \code{logical}. If \code{TRUE} distances are in kilometers, default is \code{FALSE} with distances in miles
#' @return a spatial geometry of the same class as the input AOI (if Raster sp returned)
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  # get an AOI of 'Garden of the Gods' and add a 2 mile buffer
#'     getAOI("Garden of the Gods") %>% modify(2)
#'
#'  # get an AOI of 'Garden of the Gods' and add a 2 kilometer buffer
#'     getAOI("Garden of the Gods") %>% modify(2, km = TRUE)
#'
#'  # get and AOI for Colorado Springs and subtract 3 miles
#'     getAOI("Colorado Springs") %>% modify(-3)
#' }

modify = function(AOI, d, km = FALSE){

  AOI = make_sf(AOI)

  if(km)  { u  = d * 3280.84} # kilometers to feet
  if(!km) { u  = d * 5280 }   # miles to feet

  AOI.m <- sf::st_transform(AOI, 6829)

  buff = st_buffer(AOI.m, u, joinStyle = 'MITRE', endCapStyle = "SQUARE", mitreLimit = 2)

  final = st_transform(buff, AOI::aoiProj)

  return(final)

}


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
#'

modify = function(AOI, d, km = FALSE){

  if(checkClass(AOI, 'sf')){ AOI = sf::as_Spatial(AOI)}
  if(checkClass(AOI, 'numeric')){ AOI = AOI::bbox_sp(AOI)}
  if(checkClass(AOI, 'Raster')){ AOI = AOI::bbox_sp(AOI)
  sf = FALSE}

  if(km){ d = (d * 2) * 0.621371} else {  d = 2*d }

  df = suppressMessages( describe(AOI) )

  h = df$height + d
  w = df$width  + d

  if(all(h < 0, (-h > df$height))){stop("Can't remove more then existing diminisons -- height = ", df$height)}
  if(all(w < 0, (-w > df$width))) {stop("Can't remove more then existing diminisons -- width = ",  df$width) }

  AOI.fin = getAOI(list(df$lat, df$lon, h, w), km = FALSE, sf = checkClass(AOI, 'sf'))

  return(AOI.fin)

}


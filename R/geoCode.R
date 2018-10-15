#' @title Geocoding
#' @description A wrapper around the OpenSteetMap geocoding web-services. Users can request a lat/lon pair, spatial points, and/or a bounding box geometries.\cr\cr
#' One or more locations can be given at a time. If a single point is requested, `geocode` will provide a matix of lat/lon values; a spatial point and the geocode derived bounding box (if requested).
#' If multiple points are given the returned objects will be a matrix with columns for input name-lat-lon; a SpatialPoints object; and a minimum bounding box of all input locations.
#' @param location \code{character}. Place name(s)
#' @param pt \code{logical}. If TRUE point geometery is appended to the returned list()
#' @param bb \code{logical}. If TRUE bounding box geometry is appended to the returned list()
#' @param sf \code{logical}. If TRUE object(s) returned are of class \code{sf}, default is FALSE and returns \code{sp}
#' @return at minimum a matrix of lat/lon coordinates. Possible list with appended spatial features of type \code{sf} or \code{sp}
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  ## geocode a single location
#'      geocode("UCSB")
#'  ## geocode a single location and return a SpatialPoints object
#'      geocode("UCSB", pt = TRUE)
#'  ## geocode a single location and derived bounding box of location
#'      geocode("UCSB", bb = TRUE)
#'  ## geocode multiple locations
#'      geocode(c("UCSB", "Goleta", "Sterns Warf"))
#'  ## geocode multiple points and generate a minimum bounding box of all locations
#'      geocode(c("UCSB", "Goleta", "Sterns Warf"), bb = T, pt= T)
#' }

geocode = function(location = NULL, pt = FALSE, bb = FALSE, sf = FALSE){

  if(length(location) == 1){
    df = geocodeOSM(location, pt, bb)
    return(df)
  } else {

  latlon = do.call(rbind, lapply(as.list(location), function(p){ geocodeOSM(p, pt= FALSE, bb = FALSE)} ))
  locs = data.frame(location = location, lat = as.numeric(latlon$lat), lon = as.numeric(latlon$lon))
  points = sf::st_as_sf(x = locs, coords = c('lon', 'lat'), crs = 4269) }
  if(!sf){ points = sf::as_Spatial(points)}

   if(any(bb, pt)){
     items = list(coords = locs)
     if(pt){ items[["pt"]] = points}
     if(bb){ items[["bb"]] = getBoundingBox(points, sf = sf) }
     return(items)

   } else {

      return(locs)

  }
}





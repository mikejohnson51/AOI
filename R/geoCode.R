.code = function(location, pt, bb, server) {

  if (server == 'google') {
    df <- tryCatch({
      geocodeGoogle(location, pt = pt, bb = bb)
    },
    error = function(e) {
      geocodeOSM(location, pt, bb)
    }, warning = function(w) {
      geocodeOSM(location, pt, bb)
    })
  } else {
     df = suppressWarnings(geocodeOSM(location, pt, bb))
    if (length(df) < 2) {
      df = geocodeGoogle(location, pt, bb)
    }
  }

  return(df)
}



#' @title Geocoding
#' @description A wrapper around the Google and OpenSteetMap geocoding web-services. Users can request a lat/long pair, spatial points, and/or a bounding box geometry.\cr\cr
#' One or more locations can be given at a time. If a single point is requested, `geocode` will provide a matix of lat lon vals; a spatial point and the geocode derived bounding box (if requested).
#' If multiple points are given the returned objects will be a matrix with columns for input name-lat-lon; a SpatialPoints object; and a minimum bounding box of input locations.
#' @param location place name(s)
#' @param pt logical. Should the function return a SpatialPoints object of the location(s)
#' @param bb return bb Should a bounding box geometery be returned with the object.
#' @param server what server should be prioritized. Options inlcude "google" or "osm" (default = 'google)
#' @return at minimum a matrix of lat/long coordinates
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  ## geocode a single location
#'      geocode("UCSB")
#'  #geocode a single location and return a SpatialPoints object
#'      geocode("UCSB", pt = TRUE)
#'  #geocode a single location and derived bounding box of location
#'      geocode("UCSB", bb = TRUE)
#'  #geocode multiple locations
#'      geocode(c("UCSB", "Goleta", "Sterns Warf"))
#'  #geocode multiple points and generate a minimum bounding box of all locations
#'      geocode(c("UCSB", "Goleta", "Sterns Warf"), bb = T, pt= T)
#' }

geocode = function(location = NULL, pt = FALSE, bb = FALSE, server = "google"){

if(length(location) == 1){
  df = .code(location, pt, bb, server)
  return(df)
} else {

latlon = do.call(rbind, lapply(as.list(location), function(p){ .code(p, pt= FALSE, bb = FALSE, server)} ))
locs = data.frame(location = location, lat = as.numeric(latlon$lat), lon = as.numeric(latlon$lon))
points = sf::st_as_sf(x = locs, coords = c('lon', 'lat'), crs = 4269) }

 if(any(bb, pt)){
   items = list(coords = locs)
   if(pt){ items[["pts"]] = points}
   if(bb){ items[["bb"]] = getBoundingBox(points) }
   return(items)
  } else { return(locs) }
}





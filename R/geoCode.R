code = function(location, pt, bb, server) {

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
#' @description A wrapper around the Google and OpenSteetMpa geocoding web-services. Users can request a lat/long pair, spatail points with geocoded metadata, and/or a bounding box geometry.
#' A single or mulitple locations can be input. If a single point is given `geocode` with provide a matix of lat lon a spatial point an the geocode derived bounding box (if requested).
#' If multiple points are given the retured objects will be a matrix with columns for input name:lat:lon; a collection of spatial points; and a minimum bounding box of the input locations.
#' @param location place name(s)
#' @param pt logical. Should the function return a spatial feature(s) of the location
#' @param bb return bb Should a bounding box geometery be returned with the object.
#' @param server what server should be prioritized. Options inlcude "google" or "OSM" (default = 'google)
#' @return at minimum a matrix of lat/long coordinates
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  #request a single location
#'      geocode("UCSB")
#'  #request a spatial point of location
#'      geocode("UCSB", pt = TRUE)
#'  #request a geocode derived bounding box of location
#'      geocode("UCSB", bb = TRUE)
#'  #request multiple locations
#'      geocode(c("UCSB", "Goleta", "Sterns Warf"))
#'  #request a minimum bounding box of all requested points
#'      geocode(c("UCSB", "Goleta", "Sterns Warf"), bb = T, pt= T)
#' }

geocode = function(location = NULL, pt = FALSE, bb = FALSE, server = "google"){

if(length(location) == 1){
  df = code(location, pt, bb, server)
  return(df)
} else {

latlon = do.call(rbind, lapply(as.list(location), function(p){ code(p, pt= FALSE, bb = FALSE, server)} ))
locs = data.frame(location = location, lat = as.numeric(latlon$lat), lon = as.numeric(latlon$lon))
points = sf::st_as_sf(x = locs, coords = c('lon', 'lat'), crs = 4269) }

 if(any(bb, pt)){
   items = list(coords = locs)
   if(pt){ items[["pts"]] = points}
   if(bb){ items[["bb"]] = getBoundingBox(points) }
   return(items)
  } else { return(locs) }
}






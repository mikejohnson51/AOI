#' @title Geocode via Open Street Maps API
#' @description \code{geocode} takes an input string and converts it to a geolocation.
#' Addtionally it can return the location as a simple features point and the minimun bounding area
#' of the location extent.
#' @param location a place name
#' @param pt if TRUE a simple feature point is appended to returned list
#' @param bb if TRUE the OSM bounding area of the location is appended to returned list
#' @return at minimum a data.frame of lat, long
#' @author Mike Johnson
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' geocodeOSM("UCSB")
#' geocodeOSM("Garden of the Gods", bb = TRUE)
#' }


geocodeOSM = function (location, pt = FALSE, bb = FALSE) {

  if(class(location) != 'character'){stop("\nInput location is not a place name. \nYou might be looking for reverse geocodeing.\nTry: AOI::revgeocode")}

  URL <- paste0("http://nominatim.openstreetmap.org",
                "/search?q=",
                gsub(" ", "+", location, fixed = TRUE),
                "&format=json&limit=1")

  s = jsonlite::fromJSON(URL)
  s$lat = as.numeric(s$lat)
  s$lon = as.numeric(s$lon)
  s$licence = NULL

  if( length(s) == 0 ){
    warning("No location information found for ", location)
  } else {

    if(length(s$lat) == 0){
      s$lat = NA
      s$lon = NA
    }

    loc = data.frame(lat = s$lat, lon = s$lon)

    if(pt) { point = sf::st_as_sf(x = s, coords = c("lon", "lat"), crs = as.character(AOI::aoiProj)) }

    if(bb) {
      tmp.bb = unlist(s$boundingbox)
      bbox = bbox_sp(paste(tmp.bb[3], tmp.bb[4], tmp.bb[1], tmp.bb[2], sep = ","))
    }

    if(all(!pt, !bb)) {
      return(loc)
    } else {
      items = list(coords = loc)
      if(pt){items[["pt"]] = point}
      if(bb){items[["bb"]] = bbox}
      return(items)
    }
  }
}

#' @title Geocode via Open Street Maps API
#' @description \code{geocode} takes an input string and converts it to a geolocation.
#' Addtionally it can return the location as a simple features point and the minimun bounding area
#' of the location extent.
#' @param location a place name
#' @param pt if TRUE a simple feature point is appended to returned list
#' @param bb if TRUE the OSM bounding area of the location is appended to returned list
#' @param full \code{logical}. If TRUE all OSM attributes reuturned with query, else just the lat/long pair.
#' @return at minimum a data.frame of lat, long
#' @author Mike Johnson
#' @export
#' @examples
#' \dontrun{
#' geocodeOSM("UCSB")
#' geocodeOSM("Garden of the Gods", bb = TRUE)
#' }

geocodeOSM = function (location, pt = FALSE, bb = FALSE, all = FALSE, full = FALSE) {

  if(sum(pt, bb, all) > 1){ stop("Only pt, bb, or all can be TRUE Set others to FALSE")}

  if(class(location) != 'character'){stop("\nInput location is not a place name. \nYou might be looking for reverse geocodeing.\nTry: AOI::revgeocode")}

  URL <- paste0("http://nominatim.openstreetmap.org",
                "/search?q=",
                gsub(" ", "+", location, fixed = TRUE),
                "&format=json&limit=1")

  s = data.frame(request = location, jsonlite::fromJSON(URL))
  s$lat = as.numeric(s$lat)
  s$lon = as.numeric(s$lon)
  s$licence = NULL
  s$icon = NULL

  if(length(s$lat) == 0){
      s$lat = NA
      s$lon = NA
  }

  coords = data.frame(request = location, lat = s$lat, lon = s$lon, stringsAsFactors = FALSE)

  if(pt) {
    point = sf::st_as_sf(x = if(full){s}else{coords}, coords = c("lon", "lat"), crs = as.character(AOI::aoiProj))
    return(point)
  } else if(bb) {
      tmp.bb = unlist(s$boundingbox)
      bbs = bbox_sp(paste(tmp.bb[3], tmp.bb[4], tmp.bb[1], tmp.bb[2], sep = ","))
      bbs$place_id = s$place_id
      return(if(full){merge(bbs, s)}else{bbs})
  } else if(all){
    items = list(coords = if(full){s}else{coords})
    items[['pt']] = sf::st_as_sf(x =  if(full){s}else{coords}, coords = c("lon", "lat"), crs = as.character(AOI::aoiProj))
    tmp.bb = unlist(s$boundingbox)
    bbs = bbox_sp(paste(tmp.bb[3], tmp.bb[4], tmp.bb[1], tmp.bb[2], sep = ","))
    bbs$place_id = s$place_id
    items[['bbox']] = if(full){merge(bbs, s)}else{bbs}
    return(items)
  } else {
    return(if(full){s}else{coords})
  }
}


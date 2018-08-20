#' @title Geocode via Google Maps web-services
#' @description \code{geocode} takes an input string and converts it to a geolocation.
#' Addtionally it can return the location as a simple features point and the minimun bounding area
#' of the location extent.
#' @param location a place name
#' @param pt if TRUE a simple feature point is appended to returned list
#' @param bb if TRUE the OSM bounding area of the location is appended to returned list
#' @return at minimum a data.frame of lat, long
#' @author Mike Johnson
#' @export
#' @examples
#' \dontrun{
#' geocodeGoogle("UCSB")
#' geocodeGoogle("Garden of the Gods", bb = TRUE)
#' }

geocodeGoogle = function(location, pt = FALSE, bb = FALSE){

s = jsonlite::fromJSON(paste0("https://maps.googleapis.com/maps/api/geocode/json?address=", gsub(" ", "+", location)))
if(s$status == "OVER_QUERY_LIMIT"){stop()}

f = data.frame(tmp = s$results$formatted_address, stringsAsFactors = F)
t = as.data.frame(t(unlist(s$results$address_components)), stringsAsFactors = F)
g = as.data.frame(t(unlist(s$results$geometry)), stringsAsFactors = F)

fin = c(f,t,g)

fin$address = paste(fin[grepl("long", names(fin))], collapse = ", ")

fin$bb = paste(
       fin[grepl("southwest.lng", names(fin))],
       fin[grepl("northeast.lng", names(fin))],
       fin[grepl("northeast.lat", names(fin))],
       fin[grepl("southwest.lat", names(fin))],
       sep = ",")
names(fin) = gsub("location.", "", names(fin))

x = c("viewport", "type", "short", "tmp", "long")

fin = fin[!grepl(paste(x, collapse = "|"), names(fin))]

fin = as.data.frame(fin, stringsAsFactors = F)
fin$lat = as.numeric(fin$lat)
fin$lng = as.numeric(fin$lng)

fin = fin[!duplicated(fin),]

if(pt) { point = sf::st_as_sf(x = fin, coords = c("lng", "lat"), crs = as.character(AOI::aoiProj)) }

if(bb) { bbox = bbox_sp(fin$bb) }

loc = data.frame(lat = fin$lat, lon = fin$lng)

if(all(!pt, !bb)) {return(loc)} else {
  items = list(coords = loc)
  if(pt){items[["pt"]] = point}
  if(bb){items[["bb"]] = bbox}
  return(items)
}
}


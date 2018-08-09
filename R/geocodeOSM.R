#' @title Geocode with Open Street Maps
#' @description \code{geocodeOSM} takes an input string and converts it to a geolocation.
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
#' geocodeOSM("UCSB")
#' geocodeOSM("Garden of the Gods", bb = TRUE)
#' }

geocodeOSM = function (location, pt = FALSE, bb = FALSE) {
  URL <- paste0("http://nominatim.openstreetmap.org",
                 "/search?q=",
                 gsub(" ", "+", location, fixed = TRUE),
                 "&format=xml&polygon=0&addressdetails=0")

  xx = xml2::read_xml(URL)
  xx = xml2::xml_children(xx)
  xx = xml2::xml_attrs(xx)

  if( length(xx) ==0 ){ warning("No location information found for ", location)} else {

  fin = as.data.frame(t(xx[[1]]), stringsAsFactors = F)

  fin$lat = as.numeric(fin$lat)
  fin$lon = as.numeric(fin$lon)

  if(pt) { pt = sf::st_as_sf(x = fin, coords = c("lon", "lat"), crs = as.character(AOI::aoiProj)) }

  if(bb) {

    tmp = as.numeric(unlist(strsplit(fin$boundingbox, ",")))
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

  }

  loc = data.frame(lat = fin$lat, lon = fin$lon)

  if(all(!pt, !bb)) {return(loc)} else {
    items = list(coords = loc)
    if(pt){items[["pt"]] = pt}
    if(bb){items[["bb"]] = Ps1}
    return(items)
  }
  }
}

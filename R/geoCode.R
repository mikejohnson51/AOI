#' @title Geocoding
#' @description A wrapper around the OpenSteetMap geocoding web-services. Users can request a lat/lon pair, spatial points, and/or a bounding box geometries.
#' One or more place name can be given at a time. If a single point is requested, `geocode` will provide a data.frame of lat/lon values and, if requested, a spatial point object and the geocode derived bounding box.
#' If multiple place names are given, the returned objects will be a data.frame with columns for input name-lat-lon; if requested, a SpatialPoints object will be returned; and a minimum bounding box of all place names.
#' @param location \code{character}. Place name(s)
#' @param pt \code{logical}. If TRUE point geometery is appended to the returned list()
#' @param bb \code{logical}. If TRUE bounding box geometry is appended to the returned list()
#' @param sf \code{logical}. If TRUE object(s) returned are of class \code{sf}, default is FALSE and returns \code{SpatailPolygon}
#' @return at minimum a data.frame of lat/lon coordinates. Possible list with appended spatial features of type \code{sf} or \code{sp}
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  ## geocode a single location
#'      geocode("UCSB")
#'
#'  ## geocode a single location and return a SpatialPoints object
#'      geocode("UCSB", pt = TRUE)
#'
#'  ## geocode a single location and derived bounding box of location
#'      geocode("UCSB", bb = TRUE)
#'
#'  ## geocode multiple locations
#'      geocode(c("UCSB", "Goleta", "Santa Barbara"))
#'
#'  ## geocode multiple points and generate a minimum bounding box of all locations and spatial points
#'      geocode(c("UCSB", "Goleta", "Santa Barbara"), bb = T, pt= T)
#' }

geocode = function(location = NULL, pt = FALSE, bb = FALSE, sf = FALSE){

  if(length(location) == 1){
    df = geocodeOSM(location, pt, bb)
    return(df)
  } else {

  latlon = do.call(rbind, lapply(as.list(location), function(p){ geocodeOSM(p, pt= FALSE, bb = FALSE)} ))

  locs = data.frame(location = location, lat = as.numeric(latlon$lat), lon = as.numeric(latlon$lon))
  points = sf::st_as_sf(x = locs, coords = c('lon', 'lat'), crs = 4269)
  }

  if(!sf){ points = sf::as_Spatial(points)

  }

   if(any(bb, pt)){
     items = list(coords = locs)
     if(pt){ items[["pt"]] = points}
     if(bb){ items[["bb"]] = getBoundingBox(points, sf = sf) }
     return(items)

   } else {

      return(locs)

  }
}





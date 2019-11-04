#' @title geocodeOSM
#' @description Geocode via Open Street Maps API. \code{geocodeOSM} takes an input string and converts it to a geolocation.
#' Addtionally it can return the location as a simple features point and the minimun bounding area
#' of the location extent.
#' @param location a place name
#' @param pt if TRUE a simple feature point is appended to returned list
#' @param bb if TRUE the OSM bounding area of the location is appended to returned list
#' @param all if TRUE the point and bounding box representations are returned
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

  if(sum(pt, bb, all) > 1){
    stop("Only pt, bb, or all can be TRUE. Leave others as FALSE")
  }

  if(class(location) != 'character'){
    stop("\nInput location is not a place name. \nYou might be looking for reverse geocodeing.\nTry: AOI::revgeocode")
  }

  URL <- paste0("http://nominatim.openstreetmap.org/search?q=",
                gsub(" ", "+", location, fixed = TRUE),
                "&format=json&limit=1")

  ret = jsonlite::fromJSON(URL)

  if(length(ret) != 0){
    s = data.frame(request = location, ret)
    s$lat = as.numeric(s$lat)
    s$lon = as.numeric(s$lon)
    s$licence = NULL
    s$icon = NULL
  }else{
    s = data.frame(request = location, lat = NA, lon = NA)
  }

  sub = data.frame(
    request = location,
    lat = s$lat,
    lon = s$lon,
    stringsAsFactors = FALSE)

  coords = if(full){s}else{sub}

  if(is.na(coords$lat)){ return(coords)}

  point = st_as_sf(x = coords, coords = c("lon", "lat"), crs = aoiProj)
  tmp.bb = unlist(s$boundingbox)
  bbs = bbox_sp(paste(tmp.bb[3], tmp.bb[4], tmp.bb[1], tmp.bb[2], sep = ","))
  bbs$request = s$request
  bbs = if(full){merge(bbs, s)}else{bbs}

  if(pt) { return(point) }
  if(bb) { return(bbs) }
  if(all){ return(list(coords = coords, pt = point, bbox = bbs)) }

  return(coords)

}


#' @title Pipe Re-export
#' @description re-export magrittr pipe operator
#' @importFrom magrittr %>%
#' @name %>%
#' @keywords internal
#' @export

NULL

#' @title checkClass
#' @description A function to check the class of an object, will return TRUE if `x`` is of class `type``
#' @param x an object
#' @param type a \code{character} class to check against
#' @return logical
#' @export
#' @examples
#' \dontrun{
#' sf = getAOI(state = "CA", sf = TRUE)
#' checkClass(sf, "sf")
#' }
#' @author Mike Johnson


checkClass = function(x, type) {

  fun = function(type, x){
    grepl(
      pattern = type, class(x),
      ignore.case = TRUE,fixed = FALSE
    )}

  any(sapply(type, fun, x = x ) > 0)
}


#' @title defineClip
#' @description Parse a clip list from user input. \code{defineClip} parses user supplied lists to a format usable by \code{\link{getClip}}
#' @param clip a user supplied list (see \code{\link{getAOI}})
#' @param km  \code{logical}. If \code{TRUE} distance are in kilometers,
#' default is \code{FALSE} with distances in miles
#' @noRd
#' @keywords internal
#' @return a 4-element list of features defining an AOI
#' @author Mike Johnson

defineClip = function(clip = NULL, km = FALSE) {

  # AOI defined by location and bounding box width and height

  if (length(clip) == 1) {
    if(!checkClass(clip, 'character')){
      stop("If only one item is entered for 'clip' it must be a character place name")
    } else{
      location <- clip
      h        <- NULL
      w        <- NULL
      o        <- NULL
    }
  }

  if (length(clip) == 3) {
    if (all(is.numeric(unlist(clip)))) {
      stop(
        paste0("A clip with length 3 must be defined by:\n",
               "1. A name (i.e 'UCSB') (character)\n",
               "2. A bound box height (in miles) (numeric)\n",
               "3. A bound box width (in miles) (numeric)"
        ))
    } else {
      location <- clip[[1]]
      h        <- clip[[2]]
      w        <- clip[[3]]
      o        <- 'center'
    }
  }

  # AOI defined by (centroid lat, long, and bounding box width and height) or (loaction, width, height, origin)

  if (length(clip) == 4) {

    if (any(
      !is.numeric(clip[[2]]),
      !is.numeric(clip[[3]]),
      all(!is.character(clip[[1]]), is.character(clip[[4]])),
      all(is.character(clip[[1]]), !is.character(clip[[4]]))
    )) {
      stop(
        paste0("A clip with length 4 must be defined by:\n",
               "1. A latitude (numeric)",
               "2. A longitude (numeric)\n",
               "2. A bounding box height (in miles) (numeric)\n",
               "3. A bounding box width (in miles) (numeric)\n\n",
               "OR\n\n",
               "1. A location (character)\n",
               "2. A bound box height (in miles) (numeric)\n",
               "3. A bounding box width (in miles) (numeric)\n",
               "4. A bounding box origin (character)"
        ))

    } else if (all(
      is.numeric(clip[[1]]),
      is.numeric(clip[[2]]),
      is.numeric(clip[[3]]),
      is.numeric(clip[[4]])
    )) {
      if (clip[[1]] <= -90 | clip[[1]] >= 90) {
        stop("Latitude must be vector element 1 and between -90 and 90")
      }

      if (clip[[2]] <=-179.229655487 | clip[[2]] >= 179.856674735) {
        stop("Longitude must be vector element 2 and between -180 and 180")
      }

      location <- c(clip[[1]], clip[[2]])
      h        <- clip[[3]]
      w        <- clip[[4]]
      o        <- "center"

    } else if (all(
      is.character(clip[[1]]),
      is.numeric(clip[[2]]),
      is.numeric(clip[[3]]),
      is.character(clip[[4]])
    )) {
      location <- clip[[1]]
      h        <- clip[[2]]
      w        <- clip[[3]]
      o        <- clip[[4]]

    }
  }

  # if AOI defined by lat, long, width, height, origin

  if (length(clip) == 5) {
    if (all(
      is.numeric(clip[[1]]),
      is.numeric(clip[[2]]),
      is.numeric(clip[[3]]),
      is.numeric(clip[[4]]),
      is.character(clip[[5]])
    )) {
      location <- c(clip[[1]], clip[[2]])
      h        <- clip[[3]]
      w        <- clip[[4]]
      o        <- clip[[5]]
    }
  }

  return(list(
    location = location,
    h = if(is.null(h)){NULL} else{ ifelse(km, (h*0.62137119224), h) },
    w = if(is.null(w)){NULL} else {ifelse(km, (w*0.62137119224), w) },
    o = o
  ))
}


#' @title make polygons
#' @description turn coordinates into polygon
#' @param north max latitude
#' @param east  max longitude
#' @param south min latitude
#' @param west  min latitude
#' @param crs   coordinate reference system (default aoiProj)
#' @return sf polygon
#' @export

make_polygon = function(north, east, south, west, crs = aoiProj){

  matrix(c(west, south,
           east, south,
           east, north,
           west, north,
           west, south),
         ncol = 2, byrow = TRUE) %>%
    list() %>%
    st_polygon() %>%
    st_sfc() %>%
    st_sf(crs = crs)

}



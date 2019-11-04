#' @title Convert clip unit ot geometry
#' @description
#' \code{getClip} generates a Spatial object based on a point; bounding box dimisions; and their relation to the point.
#' @param location Defined by a location or lat, long pair
#' @param height   define the height of the desired bounding box in miles
#' @param width    define the width of the desired bounding box in miles
#' @param origin   define the position of the point with respect to the bounding box. Default is set to center. Options include \itemize{
#' \item{"center"}
#'  \item{"lowerleft"}
#'   \item{"lowerright"}
#'    \item{"upperright"}
#'     \item{"upperleft"}
#'   }
#' @return a \code{SpatialPolygons} object projected to \emph{EPSG:4269}.
#' @export
#' @keywords internal
#' @author Mike Johnson


getClip = function(clip, km = FALSE){

   fin      <- defineClip(clip, km = km)
   location <- fin$location
   origin   <- fin$o

  if(all(is.null(fin$h), is.null(fin$w), is.null(origin))){
    poly <- geocode(location, bb = TRUE, full = F)
  } else {

    if(checkClass(location, "numeric")){
      location <- list(lat = location[1], lon = location[2])
    }

    if(checkClass(location, "character")){
      location <- geocode(location = location, full = FALSE)
    }

    df <- (fin$h / 2)/69                                 # north/south
    dl <- ((fin$w/ 2)/69) / cos(location$lat * pi/180)  # east/west

    if(origin == "center"){
      south <- location$lat - df
      north <- location$lat + df
      west  <- location$lon - dl
      east  <- location$lon + dl
    }

    if(origin == "lowerleft"){
      south <- location$lat
      north <- location$lat + (2*df)
      west  <- location$lon
      east  <- location$lon + (2*dl)
    }

    if(origin == "lowerright"){
        south <- location$lat
        north <- location$lat + (2*df)
        west  <- location$lon - (2*dl)
        east  <- location$lon
    }

    if(origin == "upperright"){
        south <- location$lat - (2*df)
        north <- location$lat
        west  <- location$lon - (2*dl)
        east  <- location$lon
    }

    if(origin == "upperleft"){
        south <- location$lat - (2*df)
        north <- location$lat
        west  <- location$lon
        east  <- location$lon + (2*dl)
    }

    poly = make_polygon(north, east, south, west)
  }
    return(poly)
}




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
#' @author Mike Johnson


getClip = function(location = NULL, width = NULL, height = NULL, origin = NULL){

  if(all(is.null(height), is.null(width), is.null(origin))){
    shp = geocodeGoogle(location = location, bb =TRUE)
    shp =shp$bb
  } else {

    if(class(location) == "numeric"){ location = location }

    if(class(location) == "character"){


      location = geocode(location = location)
      location = unlist(location)
    }

    if(origin == "center"){
      df = (height/2)/69                               # north/south
      dl = ((width/2)/69) / cos(location[1] * pi/180)  # east/west
      south = location[1] - df
      north = location[1] + df
      west  = location[2] - dl
      east  = location[2] + dl
    }

    if(origin == "lowerleft"){
      df = (height)/69
      dl = ((width)/69) / cos(location[1] * pi/180)
      south = location[1]
      north = location[1] + df
      west  = location[2]
      east  = location[2] + dl
    }

    if(origin == "lowerright"){
        df = (height)/69
        dl = ((width)/69) / cos(location[1] * pi/180)
        south = location[1]
        north = location[1] + df
        west  = location[2] - dl
        east  = location[2]
    }

    if(origin == "upperright"){
        df = (height)/69
        dl = ((width)/69) / cos(location[1] * pi/180)
        south = location[1] - df
        north = location[1]
        west  = location[2] - dl
        east  = location[2]
    }

    if(origin == "upperleft"){
        df = (height)/69
        dl = ((width)/69) / cos(location[1] * pi/180)
        south = location[1] - df
        north = location[1]
        west  = location[2]
        east  = location[2] + dl
    }

    coords = matrix(c(west, south,
                      east, south,
                      east, north,
                      west, north,
                      west, south),
                      ncol = 2,
                      byrow = TRUE)

    P1 = sp::Polygon(coords)
    shp = sp::SpatialPolygons(list(sp::Polygons(list(P1), ID = "a")), proj4string= aoiProj)
  }
    return(shp)
}


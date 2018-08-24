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
#' @param sf logical. Should returned feature be of class sf (default = FALSE)
#' @return a \code{SpatialPolygons} object projected to \emph{EPSG:4269}.
#' @export
#' @keywords internal
#' @author Mike Johnson


getClip = function(location = NULL, width = NULL, height = NULL, origin = NULL, sf = FALSE){

  if(all(is.null(height), is.null(width), is.null(origin))){
    shp = geocodeGoogle(location = location, bb =TRUE)
    poly =shp$bb
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

    poly = sf::st_sfc(sf::st_polygon(list(coords)), crs = 4269)

    if(!sf){ poly = sf::as_Spatial(poly)}
  }

    return(poly)
  }



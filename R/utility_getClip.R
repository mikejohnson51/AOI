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


getClip = function(location = NULL, width = NULL, height = NULL, origin = NULL){

  if(all(is.null(height), is.null(width), is.null(origin))){
    shp = geocode(location, bb = TRUE, full = F)
    poly = shp
  } else {

    if(class(location) == "numeric"){ location = list(lat = location[1], lon = location[2]) }

    if(class(location) == "character"){
      location = geocode(location = location, full = FALSE)
    }

    if(origin == "center"){
      df = (height/2)/69                               # north/south
      dl = ((width/2)/69) / cos(location$lat * pi/180)  # east/west
      south = location$lat - df
      north = location$lat + df
      west  = location$lon - dl
      east  = location$lon + dl
    }

    if(origin == "lowerleft"){
      df = (height)/69
      dl = ((width)/69) / cos(location$lat * pi/180)
      south = location$lat
      north = location$lat + df
      west  = location$lon
      east  = location$lon + dl
    }

    if(origin == "lowerright"){
        df = (height)/69
        dl = ((width)/69) / cos(location$lat * pi/180)
        south = location$lat
        north = location$lat + df
        west  = location$lon - dl
        east  = location$lon
    }

    if(origin == "upperright"){
        df = (height)/69
        dl = ((width)/69) / cos(location$lat * pi/180)
        south = location$lat - df
        north = location$lat
        west  = location$lon - dl
        east  = location$lon
    }

    if(origin == "upperleft"){
        df = (height)/69
        dl = ((width)/69) / cos(location$lat * pi/180)
        south = location$lat - df
        north = location$lat
        west  = location$lon
        east  = location$lon + dl
    }

    coords = matrix(c(west, south,
                      east, south,
                      east, north,
                      west, north,
                      west, south),
                      ncol = 2,
                      byrow = TRUE)

    poly = sf::st_sf(sf::st_sfc(sf::st_polygon(list(coords)), crs = 4269))
    names(poly) = "geometry"
    sf::st_geometry(poly)  <- "geometry"
  }

    return(poly)
  }



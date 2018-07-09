#' Get a bouding box for a location
#'
#' @description
#' \code{getClip} generates a \code{SpatialPolygon} based on bounding box dimisions its relation to a point.
#'  All HydroData outputs are projected to \emph{EPSG:4269}.
#'  Locations given by a character string are geocoded via the \code{dismo} package to get a lat, long pair. All bounding boxes defined by a width an a height.
#'  The point from chich these are drawn ins defined by a given location and origin.
#'
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
#'
#' @return a \code{SpatialPolygons} object projected to \emph{EPSG:4269}.
#' @export
#' @seealso \itemize{
#'          \item \code{\link{getClip}}
#'          }
#'
#' @examples

#' \dontrun{
#'
#'
#' # Get AOI defined by 10 mile bounding box using "UCSB" as the point
#'     getClip(location = "UCSB", width = 10, height = 10, origin = "center")
#'
#' # Get AOI defined by 10 mile2 bounding box using the 'KMART near UCSB' as lower left corner
#'     getClip(clocation = NULL, width = NULL, height = NULL, origin = NULL)
#'}
#'
#' @author
#' Mike Johnson


getClip = function(location = NULL, width = NULL, height = NULL, origin = NULL){

    if(class(location) == "numeric"){ location = location }

    if(class(location) == "character"){
      location = getPoint(name = location)
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
    return(shp)
}


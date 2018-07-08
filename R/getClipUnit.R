#' Get a bouding box for a location
#'
#' @details
#' \code{getClipUnit} generates a \code{SpatialPolygon} based on a location, bounding box height and width and point position.
#'  All HydroData outputs are projected to \emph{'+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0+no_defs'}.
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
#' @return \code{getClipUnit} returns a \code{SpatialPolygon} Object
#' @export
#' @seealso \itemize{
#'          \item \code{\link{getFiatBoundary}}
#'          \item \code{\link{getAOI}}
#'          }
#'
#' @family HydroData 'get' functions
#'
#' @examples
#' \dontrun{
#' # Get clip unit using name
#'     get
#'
#' # Get Multi-state
#'     getFiatBoundary(state = c("CA","Utah","Nevada"))
#'
#' # Get County
#'     getFiatBoundary(state = "CA", county = "San Luis Obispo")
#'
#' # Get Muli-county
#'    getFiatBoundary(state = "CA", county = c("San Luis Obispo", "Santa Barbara", "Ventura"))
#'
#' # Get counties that intersect with defined clip_unit
#'    getFiatBoundary(clip_unit = list("UCSB", 10, 10, "lowerleft"))
#'}
#'
#' @author
#' Mike Johnson


getClipUnit = function(location = NULL, width = NULL, height = NULL, origin = NULL){

    if(class(location) == "numeric"){ location = location }
   # if(is.null(origin)){ origin = 'center' }

    if(class(location) == "character"){
      location = getPoint(name = 'UCSB')
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
    shp = sp::SpatialPolygons(list(sp::Polygons(list(P1), ID = "a")), proj4string= HydroDataProj)
    return(shp)
}


#' @title Buffer AOI
#' @description Add or subtract a uniform distance to/from a spatial object in either miles or kilometers.
#' @param AOI a spatial, raster or simple features object
#' @param d \code{numeric}.The distance by which to modify each edge
#' @param km \code{logical}. If \code{TRUE} distances are in kilometers, default is \code{FALSE} with distances in miles
#' @return a spatial geometry of the same class as the input AOI (if Raster sp returned)
#' @export
#' @examples
#' \dontrun{
#'  # get an AOI of 'Garden of the Gods' and add a 2 mile buffer
#'     AOI = aoi_get("Garden of the Gods") %>% modify(2)
#'
#'  # get an AOI of 'Garden of the Gods' and add a 2 kilometer buffer
#'     getAOI("Garden of the Gods") %>% modify(2, km = TRUE)
#'
#'  # get and AOI for Colorado Springs and subtract 3 miles
#'     getAOI("Colorado Springs") %>% modify(-3)
#' }

aoi_buffer = function(AOI, d, km = FALSE){

  AOI = make_sf(AOI)

  crs = st_crs(AOI)

  if(km)  { u  = d * 3280.84} # kilometers to feet
  if(!km) { u  = d * 5280 }   # miles to feet

  st_transform(AOI, 6829) %>%
    st_buffer(u, joinStyle = 'MITRE', endCapStyle = "SQUARE", mitreLimit = 2) %>%
    st_transform(crs)
}

#' @title Is Inside
#' @description A check to see if one object is inside another
#' @param obj object 1
#' @param AOI object 2
#' @param total boolean. If \code{TRUE} then check if obj is competely inside the AOI.
#' If \code{FALSE}, then check if at least part of obj is in the AOI.
#' @return boolean value
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'   AOI = getAOI(state = "CA")
#'   obj = getAOI(state = "CA", county = "Santa Barbara")
#'   is_inside(AOI, obj)
#'
#'   AOI = getAOI(state = "CA")
#'   obj = getAOI(state = "CO", county = "El Paso")
#'   is_inside(AOI, obj)
#' }


aoi_inside = function(AOI, obj, total = TRUE){

  AOI = make_sf(AOI)
  obj = make_sf(obj) %>% sf::st_transform(sf::st_crs(AOI))

  int = suppressMessages( sf::st_intersects(obj, AOI) )

  if (!apply(int, 1, any)) {
    return(FALSE)
  } else {
    x = suppressWarnings(
      suppressMessages( sf::st_intersection(obj, AOI) ))

    inside = any(x$geometry == AOI$geometry, x$geometry == obj$geometry)

    if (total) {
      return(inside)
    } else{
      return(TRUE)
    }
  }
}

#' @title Convert raster and sp objects to sf
#' @description Convert raster and sp objects to sf
#' @param x any spatial object
#' @return an sf object
#' @keywords internal
#' @author Mike Johnson

make_sf = function(x){

  if (grepl("Raster", class(x)[1]))  {
    x = bbox_get(x)
  } else if (grepl("Spatial", class(x)[1])) {
    x = st_as_sf(x)
  } else if (methods::is(x, "sf"))     {
    x = st_as_sf(x)
  } else {
    x = NULL
  }

  return(x)
}


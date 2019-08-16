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


is_inside = function(AOI, obj, total = T){

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






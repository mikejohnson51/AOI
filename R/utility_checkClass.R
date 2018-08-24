#' @title Check an objects class
#' @description A function to check the class of an object, will return TRUE if `x`` is of class `type``
#' @param x an object
#' @param type a \code{character} class to check against
#' @return logical
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' sf = getAOI(state = "CA", sf = TRUE)
#' checkClass(sf, "sf")
#' }
#' @author Mike Johnson

checkClass = function(x, type) {
  log = any(grepl(
    pattern = type,
    class(x),
    ignore.case = TRUE,
    fixed = FALSE
  ))

  return(log)
}




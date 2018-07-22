#' Check Objects Class
#'
#' @description A function check the class of an object, will return TRUE if x is of class type
#'
#' @param x an object
#' @param type a class
#'
#' @return logical
#'
#' @examples
#' \dontrun{
#' sp = getAOI(state = "CA", sf = TRUE)
#' checkClass(sp, "sf")}
#'
#' @family HydroData 'utility' function



checkClass = function(x, type){

  log = any(grepl(
    pattern = type,
    class(x),
    ignore.case = T,
    fixed = F
  ))

  return(log)
}




#' Lower case first character
#'
#' @description  \code{simpleCap} lower cases the first character of a string
#'
#' @param s a string to be parsed.
#'
#' @examples
#' /dontrun{ simpleCap("santa barbara") }
#' @export
#'
#' @author Mike Johnson
#' @family AOI 'utility'


firstLower <- function(s) {
  substr(s, 1, 1) <- tolower(substr(s, 1, 1))
  return(s)
}

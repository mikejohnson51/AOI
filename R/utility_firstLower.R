#' @title Lower case first character
#' @description  \code{firstLower} lower cases the first character of a string
#' @param x a string to be parsed.
#' @author Mike Johnson
#' @examples
#' firstLower("SANTA BARBARA")

firstLower <- function(x) {
  substr(x, 1, 1) <- tolower(substr(x, 1, 1))
  return(x)
}



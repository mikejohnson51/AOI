#' A function for capitilizing all words in a string
#'
#' @param x a string to be parsed.
#'
#' @examples
#' simpleCap("santa barbara")
#'
#' @export
#' @author
#' Mike Johnson
#'


simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

firstLower <- function(x) {
  substr(x, 1, 1) <- tolower(substr(x, 1, 1))
  return(x)
}


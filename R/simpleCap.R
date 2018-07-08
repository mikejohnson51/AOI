#' Camel Case
#'
#' @description  \code{simpleCap} capitilizes all words in a given text string
#'
#' @param x a string to be parsed.
#'
#' @examples
#' simpleCap("santa barbara")
#' @export
#'
#' @author Mike Johnson
#' @family AOI 'utility'

simpleCap <- function(x) {

  x = tolower(x)

  vals = vector(mode = "character", length = length(x))

  for(i in 1:length(x)){
    s <- strsplit(x, " ")[[i]]
    vals[i] = paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
  }

  return(vals)
}

#' Lower case first character
#'
#' @description  \code{simpleCap} lower cases the first character of a string
#'
#' @param x a string to be parsed.
#'
#' @examples
#' simpleCap("santa barbara")
#' @export
#'
#' @author Mike Johnson
#' @family AOI 'utility'


firstLower <- function(x) {
  substr(x, 1, 1) <- tolower(substr(x, 1, 1))
  return(x)
}


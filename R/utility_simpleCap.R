#' Camel Case (Simple Capitalization)
#'
#' @description  \code{simpleCap} capitilizes all words in a given text string
#'
#' @param x a text \code{character} string
#'
#' @examples
#' \dontrun{
#' simpleCap("santa barbara")
#' }
#'
#' @export
#' @author Mike Johnson


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

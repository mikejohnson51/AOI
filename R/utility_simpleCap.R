#' @title Camel Case (Simple Capitalization)
#' @description  \code{simpleCap} capitilizes all words in a given text string
#' @param x a string
#' @author Mike Johnson
#' @export
#' @noRd
#' @examples
#' \dontrun{
#' simpleCap("santa barbara")
#' }

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

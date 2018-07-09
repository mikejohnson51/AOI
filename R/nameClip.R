#' Provide the plain-english description of a clip unit
#'
#' @description This function is a mirror of \code{\link{getAOI}} but instead of returning a \code{SpatilaPolygons} object,
#' returns a plain-english description of the clip list (eg: 'AOI defined as a 10 mile tall by 10 mile wide region centered on (the) UCSB')
#'
#' @param clip a user supplied clip list (see \code{\link{getAOI}} and \code{\link{getClip}})
#'
#' @return a string describing the clip list in plain english
#' @author Mike Johnson
#' @export


nameClip = function(clip){

test = defineClip(clip)

if(class(test$location) == 'numeric'){
 test$location =  paste(paste(round(test$location,2), collapse = "/"), "(lat/lon)")
} else { test$location =  paste("(the)", test$location)}

if(test$o == 'center'){
   name = paste0("A ", test$h, " mile tall by ", test$w, " mile wide region centered on ", test$location)
} else{

if(test$o == "lowerright"){ test$o = "lower right corner"}
if(test$o == "lowerleft"){ test$o = "lower left corner"}
if(test$o == "upperright"){ test$o = "upper right corner"}
if(test$o == "upperleft"){ test$o = "upper left corner"}

name = paste0("A ", test$h, " mile tall by ", test$w, " mile wide region with ",  test$location, " in the ", test$o)

return(name)

}
}


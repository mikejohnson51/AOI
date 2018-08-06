#' @title Provide the plain-english description of a clip region
#' @description Return a plain-english description of the clip list
#' (eg: 'AOI defined as a 10 mile tall by 10 mile wide region centered on (the) UCSB')
#' @param clip a user supplied clip list (see \code{\link{getAOI}} and \code{\link{getClip}})
#' @param km  \code{logical}. If \code{TRUE} distance are in kilometers,  default is \code{FALSE} and with distances in miles
#' @return a string describing the clip region in plain english
#' @author Mike Johnson


nameClip = function(clip, km = FALSE){

test = defineClip(clip, km = km)

test$h = ifelse(km, round(test$h * 1.609344,2), test$h)
test$w = ifelse(km, round(test$w * 1.609344,2), test$w)
dist = ifelse(km, " kilometer", " mile")

if(class(test$location) == 'numeric'){
 test$location =  paste(paste(round(test$location,2), collapse = "/"), "(lat/lon)")
} else { test$location =  paste("(the)", test$location)}

if(test$o == 'center'){
   name = paste0("A ", test$h, dist , " tall by ", test$w, dist," wide region centered on ", test$location)
} else{

if(test$o == "lowerright"){ test$o = "lower right corner"}
if(test$o == "lowerleft"){ test$o = "lower left corner"}
if(test$o == "upperright"){ test$o = "upper right corner"}
if(test$o == "upperleft"){ test$o = "upper left corner"}

name = paste0("A ", test$h, dist, " tall by ", test$w, dist," wide region with ",  test$location, " in the ", test$o)

return(name)

}
}


#' Interprete the plain-english description of a clip unit
#'
#' @param clip_unit a user supplied clip_unit
#'
#' @return a string describing the clipt unit in plain english
#' @family HydroData 'helper' functions
#' @author Mike Johnson
#' @export


name.clip.unit = function(clip_unit){

test = define.clip.unit(clip_unit)

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

print.bb = function(x){
  cat("Bounding Box:\n")

  for(i in 1:NCOL(x)){
    cat(paste0("\n", names(x)[i], paste(rep(" ", 4 - nchar(names(x)[i])), collapse = ""), ":\t"))
    cat(paste(round(x[i], 4)))
  }

}

#' @title Bounding box as string
#' @description Convert an AOI or spatial object to a data.frame of xmin, xmax, ymin, ymax
#' @param AOI an AOI obtained using \link{getAOI}.
#' @return a bb oject
#' @export
#' @author Mike Johnson
#' @examples
#' #Get a bounding box data.frame for AOI
#' AOI = getAOI(clip = list("UCSB", 10, 10))
#' bb = bbox_st(AOI)
#' print(bb)
#'
#' # Chain to AOI calls:
#' AOI = getAOI(clip = list("UCSB", 10, 10)) %>% bbox_st()
#' print(AOI)

bbox_st = function(AOI){

  if(any(class(AOI) == 'sf')){AOI = sf::as_Spatial(AOI)}

  bb =  data.frame(xmin = AOI@bbox[1,1],
         xmax = AOI@bbox[1,2],
         ymin = AOI@bbox[2,1],
         ymax = AOI@bbox[2,2])

  class(bb) = c("bb", class(bb))

  return(bb)

}




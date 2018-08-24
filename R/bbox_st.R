print.bb = function(x){
  cat("Bounding Box:\n")

  for(i in 1:NCOL(x)){
    cat(paste0("\n", names(x)[i], paste(rep(" ", 4 - nchar(names(x)[i])), collapse = ""), ":\t"))
    cat(paste(round(x[i], 4)))
  }

}

#' @title Convert spatial geometry to string (data.frame)
#' @description Convert a spatial object to a data.frame of (xmin, xmax, ymin, ymax)
#' @param AOI any spatial object (raster, sf, sp)
#' @return a bounding box data.frame
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#' ## Get a bounding box data.frame for AOI
#'    AOI = getAOI(list("UCSB", 10, 10)) %>% bbox_st()
#' }


bbox_st = function(AOI){

  if(any(class(AOI) == 'sf')){AOI = sf::as_Spatial(AOI)}
  if(checkClass(AOI, 'Raster')){ AOI = getBoundingBox(AOI)}

  bb =  data.frame(xmin = AOI@bbox[1,1],
                   xmax = AOI@bbox[1,2],
                   ymin = AOI@bbox[2,1],
                   ymax = AOI@bbox[2,2])

  class(bb) = c("bb", class(bb))

  return(bb)

}

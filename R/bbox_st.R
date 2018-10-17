print.bb = function(x){
  cat("Bounding Box:\n")

  for(i in 1:NCOL(x)){
    cat(paste0("\n", names(x)[i], paste(rep(" ", 4 - nchar(names(x)[i])), collapse = ""), ":\t"))
    cat(paste(round(x[i], 4)))
  }

}

#' @title Convert spatial geometries to a data.frame of coordinates
#' @description Convert a spatial (sp/sf) object to a data.frame of ("xmin", "xmax", "ymin", "ymax")
#' @param AOI any spatial object (\code{raster}, \code{sf}, \code{sp}). Can be piped (\%>\%) from \code{\link{getAOI}}
#' @return a data.frame containing xmin. xmax, ymin, ymax coordinates
#' @export
#' @author Mike Johnson
#' @seealso \code{\link{bbox_sp}}
#' @examples
#' \dontrun{
#' ## Get a bounding box data.frame for AOI
#'    AOI = getAOI(list("UCSB", 10, 10)) %>% bbox_st()
#'
#' >   xmin     xmax    ymin     ymax
#' >  -119.9337 -119.758 34.34213 34.48706
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

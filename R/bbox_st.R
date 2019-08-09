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
  bb = st_bbox(AOI)
  df = data.frame(xmin = bb[1], ymin = bb[2], xmax = bb[3], ymax = bb[4], row.names = NULL )
  return(df)

}

#' Get a Google base Map via Dismo package gmap
#'
#' \code{getBasemape} wraps the \code{\link[dismo]{gmap}} function in the framework of HydroData
#'
#' @param AOI an Area of Intrest Object generated with \code{getAOI}
#' @param type detemrines the type of base map returned. Choose from:
#' \itemize{
#' \item 't':  a terrain imagery basemap (DEFAULT IF  \code{NULL})
#' \item 's':  a sattilite imagery basemap
#' \item 'h':  a hybrid imagery basemap
#' \item 'r':  a roadmap imagery basemap
#' }
#' @export
#' @importFrom dismo gmap
#'
#' @seealso
#' \code{\link[dismo]{gmap}}
#'
#' @examples
#' \dontrun{
#'  plot(getBasemap(getAOI(state = "CA", county = "Santa Barbara"), type = 's'))
#'
#' }
#'
#' @author Mike Johnson
#' @family HydroData 'get' function
#'
#'
getBasemap = function(AOI = NULL, type = NULL){
  if (is.null(type)){ type = 't'}
  if (!(type %in% c('s', 'h', 't', 'r'))){ stop("'type' must be 's' (satellite), 'h' (hybrid), 'r' (roadmap), or 't' (terrain)")}
  if (type == 't') { type = 'terrain'}
  if (type == 'h') { type = 'hybrid'}
  if (type == 's') { type = 'satellite'}
  if (type == 'r') { type = 'roadmap'}

  bmap = gmap (AOI, lonlat = TRUE, type = type, scale = 2)
  return (bmap)
}




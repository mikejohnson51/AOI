#' @title AOI Projection
#' @description The projection used for all AOI calls: \emph{EPSG:4269}
#' @export
#' @author Mike Johnson

aoiProj = sp::CRS('+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0+no_defs')

#' @title Describe an AOI
#' @description Describe a spatial (sf/sp/raster) object in terms of a reproducable AOI  (e.g. \code{\link{aoi_get}}) parameters.
#' @param AOI a spatial object (\code{raster}, \code{sf}, \code{sp}).
#' @param full if TRUE, reverse geocoding descriptions returned, else just lat, lon, width, height, and origin (default = FALSE)
#' @param km if TRUE, units are in kilometers, else in miles (default = FALSE)
#' @return a data.frame of AOI descriptors including (at minimum):
#' \describe{
#'   \item{lat}{the AOI center latitude }
#'   \item{lon}{the AOI center longitude}
#'   \item{height}{ height in (miles)}
#'   \item{width}{width in(miles)}
#'   \item{origin}{AOI origin}
#' }
#' @export
#' @examples
#'  {library(AOI)
#'  aoi_get("UCSB") %>% aoi_describe()
#'  aoi_get("UCSB") %>% aoi_describe(full = TRUE)
#'  }


aoi_describe = function(AOI, full = FALSE, km = FALSE){

  if(methods::is(AOI, 'Raster')){ AOI = bbox_get(AOI)}

  bb = st_transform(AOI, aoiProj) %>% bbox_coords()

  latCent = (bb$ymin + bb$ymax) / 2

  df = data.frame(
    lat = latCent,
    lon = (bb$xmin + bb$xmax) / 2,
    height  = round(69 * (abs(bb$ymax - bb$ymin)), 2),
    width   = round(69 * cos(latCent * pi/180) * abs(abs(bb$xmax) - abs(bb$xmin)), 2),
    origin  = "center",
    units = "miles",
    stringsAsFactors = F
    )

  if(km){
    df$height = df$height / 1.609
    df$width = df$width / 1.609
    df$units = "kilometers"
  }

  if(full) {
    rc = geocode_rev(x = c(df$lat, df$lon))
    if (!is.null(rc$match_addr)) {
      df[["name"]]    = rc$match_addr
    } else {
      df[["name"]] = rc[1]
    }

    df[['area']] = df$height * df$width
  }

  rownames(df) = NULL

  return(df)

}






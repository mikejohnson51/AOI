#' @title Describe an AOI
#' @description Describe a spatial, raster or sf object in terms of a reproducable clip area (e.g. \code{\link{getAOI}}) parmaters.
#' @param AOI any spatial object (\code{raster}, \code{sf}, \code{sp}).
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
#' @author Mike Johnson
#' @examples
#' \dontrun{
#'  AOI = getAOI("UCSB") %>% describe()
#'
#'  ```
#'  lat     :	34.41456
#'  lon     :	-119.8605796
#'  height  :	1
#'  width   :	3
#'  origin  :	center
#'  ```
#'
#'  AOI = getAOI("UCSB") %>% describe(full = TRUE)
#'
#'  ```
#'  lat     :	34.41456
#'  lon     :	-119.8605796
#'  height  :	1
#'  width   :	3
#'  origin  :	center
#'  name    :	6650 Abrego Rd, Goleta, California, 93117
#'  area    :	3 square miles
#'  ```
#' }

describe = function(AOI, full = FALSE, km = FALSE){

  if(checkClass(AOI, 'raster')){ AOI = getBoundingBox(AOI)}

  bb = st_transform(AOI, aoiProj) %>% bbox_st()

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
    rc = revgeocode(point = c(df$lat, df$lon))
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






#' @title Describe an AOI
#' @description Describe a spatial (sf/sp/raster) object in terms of a
#'              reproducable AOI  (e.g. \code{\link{aoi_get}}) parameters.
#' @param AOI a spatial object (\code{raster}, \code{sf}, \code{sp}).
#' @param full if TRUE, reverse geocoding descriptions returned, else just
#'             lat, lon, width, height, and origin (default = FALSE)
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
#' {
#'   fname <- system.file("shape/nc.shp", package = "sf")
#'   nc <- sf::read_sf(fname)
#'   aoi_describe(nc[1, ])
#' }
aoi_describe <- function(AOI, full = FALSE, km = FALSE) {
  AOI <- make_sf(AOI)
  bb <- sf::st_transform(AOI, 4269) %>%
    bbox_coords()

  lat_cent <- (bb$ymin + bb$ymax) / 2

  df <- data.frame(
    lat = lat_cent,
    lon = (bb$xmin + bb$xmax) / 2,
    height = round(
      69 * (abs(bb$ymax - bb$ymin)),
      digits = 2
    ),
    width = round(
      69 * cos(lat_cent * pi / 180) * abs(abs(bb$xmax) - abs(bb$xmin)),
      digits = 2
    ),
    origin = "center",
    units = "miles",
    stringsAsFactors = FALSE
  )

  if (km) {
    df$height <- df$height / 1.609
    df$width <- df$width / 1.609
    df$units <- "kilometers"
  }

  if (full) {
    rc <- geocode_rev(x = c(df$lat, df$lon))
    df <- cbind(df, rc)

    df[["area"]] <- df$height * df$width
  }

  df
}

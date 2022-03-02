#' @title Describe an AOI
#' @description Describe a spatial (sf/sp/raster) object in terms of a
#'              reproducible AOI  (e.g. \code{\link{aoi_get}}) parameters.
#' @param AOI a spatial object (\code{raster}, \code{sf}, \code{sp}).
#' @return a data.frame of AOI descriptors
#' @export
#' @examples
#' {
#'   fname <- system.file("shape/nc.shp", package = "sf")
#'   nc <- sf::read_sf(fname)
#'   aoi_describe(AOI = nc[1, ])
#' }
#' @importFrom sf st_transform st_bbox
#'

aoi_describe = function(AOI){

  if(any(sf::st_is(AOI, "POLYGON") | sf::st_is(AOI, "MULTIPOLYGON"))){
    tot_area  = sum(sf::st_area(AOI)) / 1e6
    bb            = sf::st_bbox(AOI)
    bb_area       = sf::st_area(sf::st_as_sfc(bb)) / 1e6
    coverage_per  = 100 * (tot_area / bb_area)
    tot_units = nrow(AOI)
    geom = "POLYGON"
  } else {
    tot_area      = NULL
    bb            = sf::st_bbox(AOI)
    bb_area       = sf::st_area(sf::st_as_sfc(bb)) / 1e6
    coverage_per  = NULL
    tot_units     = nrow(AOI)
    geom = "POINT"
  }

  lat_cent = (bb$ymin + bb$ymax) / 2
  lon_cent = (bb$xmin + bb$xmax) / 2
  height = round(69 * (abs(bb$ymax - bb$ymin)), digits = 4)
  width = round(
      69 * cos(lat_cent * pi / 180) * abs(abs(bb$xmax) - abs(bb$xmin)),
      digits = 4)

  {
    cat("type:\t\t",  geom  , paste0("(", tot_units, ")\n"))
    cat("BBox Area:\t",  bb_area  , "[km^2]\n")
    cat("Centroid:\t",  lon_cent, lat_cent  , "[x,y]\n")
    cat("Diminsions:\t",  width, height  , "[width, height, in miles]\n")
    if(geom != "POINT"){
      cat("area:\t\t",  tot_area  , "[km^2]\n")
      cat("Area/BBox Area:\t",  coverage_per  , "[%]\n")
    }
  }
}


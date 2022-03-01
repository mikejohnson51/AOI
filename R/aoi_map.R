#' @title Generate Leafet map and tool set for AOI
#' @description
#' Provides a precanned leaflet layout for checking, and refining AOI queries.
#' Useful \code{leaflet} tools allow for the marking of points, measuring of
#' distances, and  panning and zooming.
#' @param AOI any spatial object (\code{raster}, \code{sf}, \code{sp}).
#'            Can be piped (\%>\%) from \code{\link{aoi_get}}.
#'            If \code{AOI = NULL}, base map of CONUS will be returned.
#' @param returnMap \code{logical}. If \code{FALSE} (default) the input
#'                  AOI is returned and the leaflet map printed.
#'                  If \code{TRUE} the leaflet map is returned and printed.
#' @return a \code{leaflet} html object
#' @examples
#' \dontrun{
#' ## Generate an empty map:
#' aoi_map()
#'
#' ## Check a defined AOI:
#' AOI <- getAOI(clip = list("UCSB", 10, 10))
#' aoi_map(AOI)
#'
#' ## Chain to AOI calls:
#' getAOI(clip = list("UCSB", 10, 10)) %>% aoi_map()
#'
#' ## Add layers with standard leaflet functions:
#' r <- getAOI("UCSB") %>% # get AOI
#'   HydroData::findNWIS() # get SpatialPointsDataframe of local USGS gages
#'
#' aoi_map(r$AOI) %>%
#'   addMarkers(data = r$nwis, popup = r$nwis$site_no)
#'
#' ## Save map for reference:
#' m <- getAOI("Kansas City") %>% aoi_map()
#' htmlwidgets::saveWidget(m, file = paste0(getwd(), "/myMap.html"))
#' }
#' @export
#' @importFrom sf st_geometry_type

aoi_map <- function(AOI = NULL, returnMap = FALSE) {

  check_pkg('leaflet')

  p <- "+proj=longlat +datum=WGS84"
  m <- NULL
  bb <- NULL
  pts <- NULL
  type <- NULL
  out <- NULL
  orig <- AOI

  if (!inherits(AOI, "list")) {
    AOI <- list(AOI = AOI)
  }

  for (i in seq_len(length(AOI))) {
    tmp <- make_sf(AOI[[i]])

    if (!is.null(tmp)) {
      out[[length(out) + 1]] <- st_transform(tmp, p)
      type[length(type) + 1] <- as.character(unique(st_geometry_type(tmp)[1]))
    }
  }


  if ("POINT" %in% type) {
    pts <- out[[which(grepl("POINT", type))]]
  }

  if ("POLYGON" %in% type) {
    bb <- out[[which(grepl("POLYGON", type))]]
  }

  if ("MULTIPOLYGON" %in% type) {
    bb <- out[[which(grepl("MULTIPOLYGON", type))]]
  }


  m <- leaflet::leaflet()  |>
    leaflet::addProviderTiles("Esri.NatGeoWorldMap", group = "Terrain")  |>
    leaflet::addProviderTiles("CartoDB.Positron", group = "Grayscale")  |>
    leaflet::addProviderTiles("Esri.WorldImagery", group = "Imagery")  |>
    leaflet::addScaleBar("bottomleft")  |>
    leaflet::addMiniMap(
      toggleDisplay = TRUE,
      minimized = TRUE
    )  |>
    leaflet::addMeasure(
      position = "bottomleft",
      primaryLengthUnit = "feet",
      primaryAreaUnit = "sqmiles",
      activeColor = "red",
      completedColor = "green"
    )  |>
    leaflet::addLayersControl(
      baseGroups = c("Terrain", "Grayscale", "Imagery"),
      options = leaflet::layersControlOptions(collapsed = TRUE)
    )

  if (is.null(orig)) {
    m <- leaflet::setView(m, lat = 39.311825, lng = -101.275972, zoom = 4)
  } else {
    if (!is.null(pts)) {
      m <- leaflet::addMarkers(m, data = pts)
    }

    if (!is.null(bb)) {
      m <- leaflet::addPolygons(m,
        data = bb,
        stroke = TRUE,
        fillColor = "transparent",
        color = "red",
        opacity = 1
      )
    }
  }

  message(m)

  if (returnMap) {
    m
  } else {
    orig
  }
}

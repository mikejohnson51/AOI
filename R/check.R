#' @title Generate Leafet map and tool set
#' @description Generate an interactive \code{leaflet} map for checking, and refining AOI queries. Useful \code{leaflet} tools allow for the marking of points, measuring of distances, and interactive panning and zooming to help define
#' an approapriate AOI.
#' @param AOI any spatial, raster or sf object. Can be left \code{NULL}
#' @return a \code{leaflet} html object
#' @examples
#' \dontrun{
#' ## Generate an empty map:
#'      check()
#'
#' ## Check a defined AOI:
#'      AOI = getAOI(clip = list("UCSB", 10, 10))
#'      check(AOI)
#'
#' ## Chain to AOI calls:
#'      getAOI(clip = list("UCSB", 10, 10)) %>% check()
#'
#' ## Add layers with standard leaflet functions:
#'      r = getAOI("UCSB") %>%  # get AOI
#'      HydroData::findNED() %>%  # get raster of elevation data
#'      HydroData::findNWIS() # get SpatialPointsDataframe of local USGS gages
#'
#'      check(r$NED) %>% addMarkers(data = r$nwis, popup = r$nwis$site_no)
#'
#' ## Save map for reference:
#'      m = getAOI("Kansas City") %>% check()
#'      htmlwidgets::saveWidget(m, file = paste0(getwd(), "/myMap.html"))
#' }
#' @export
#' @author Mike Johnson

check = function(AOI = NULL) {

  if(checkClass(AOI, 'sf')){
    AOI = sf::st_transform(AOI, '+proj=longlat +datum=WGS84')
  }

  if(checkClass(AOI, 'raster')){
    AOI = getBoundingBox(AOI)
  }

  base= leaflet() %>%
    addProviderTiles("Esri.NatGeoWorldMap", group = "Terrain") %>%
    addProviderTiles("CartoDB.Positron",    group = "Grayscale") %>%
    addProviderTiles("Esri.WorldImagery",   group = "Imagery") %>%
    addScaleBar("bottomleft") %>%
    addMiniMap(
               toggleDisplay = TRUE,
               minimized = TRUE) %>%
    addMeasure(
      position = "bottomleft",
      primaryLengthUnit = "feet",
      primaryAreaUnit = "sqmiles",
      activeColor = "red",
      completedColor = "green"
    ) %>%
    addLayersControl(
      baseGroups = c("Terrain", "Grayscale", "Imagery"),
      options = layersControlOptions(collapsed = T)
    )

  if(is.null(AOI)){
    m = setView(base, lat = 39.311825, lng = -101.275972, zoom = 4)
  } else {
    m = addPolygons(base,
      data = AOI,
      stroke = TRUE,
      fillColor = 'transparent',
      color = "red",
      opacity = 1
    )
  }

  print(m)

  return(m)

}


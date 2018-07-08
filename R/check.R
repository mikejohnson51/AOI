#' Check AOI extents
#'
#' @param AOI an AOI obtained from \code{getAOI}
#'
#' @return a leaflet map object
#' @export
#' @author Mike Johnson

check = function(AOI = NULL) {

  m = leaflet() %>%
    addProviderTiles("CartoDB.Positron", group = "Base") %>%
    addProviderTiles("Esri.WorldImagery", group = "Imagery") %>%
    addProviderTiles("Esri.NatGeoWorldMap" , group = "Terrain") %>%

    addScaleBar("bottomleft") %>%
    addMiniMap(tiles = providers$OpenStreetMap.BlackAndWhite,
               toggleDisplay = TRUE, minimized = TRUE) %>%
    addMeasure(
      position = "bottomleft",
      primaryLengthUnit = "feet",
      primaryAreaUnit = "sqmiles",
      activeColor = "red",
      completedColor = "green"
    ) %>%
    addLayersControl(
      baseGroups = c("Base", "Imagery", "Terrain"),
      options = layersControlOptions(collapsed = T)
    )

  if(is.null(AOI)){
    m = setView(m , lat = 39.311825, lng = -101.275972, zoom = 4)
  }

  if(!is.null(AOI)){
    m = addPolygons(m,
      data = AOI,
      stroke = TRUE,
      fillColor = 'transparent',
      color = "red",
      opacity = 1
    )
  }

  return(m)

}


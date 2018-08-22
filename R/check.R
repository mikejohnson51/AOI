#' @title Vizualize AOIs
#' @description Generate an interactive \code{leaflet} map for defining, checking, and refining AOI queries. Can be chained to \link{getAOI} via
#' `%>%`. Useful \code{leaflet} tools allow for the marking of points, measuring of distances, and interactive panning and zooming to help define
#' an approapriate AOI.
#' @param AOI an AOI obtained using \link{getAOI} or any/sf. Can be left \code{NULL}
#' @return a list of AOI and \code{leaflet} html object
#' @examples
#' \dontrun{
#' # Generate an empty map:
#' check()
#'
#' # Check a defined AOI:
#' AOI = getAOI(clip = list("UCSB", 10, 10))
#' check(AOI)
#'
#' # Chain to AOI calls:
#' getAOI(clip = list("UCSB", 10, 10)) %>% check()
#' }
#' @export
#' @author Mike Johnson

check = function(AOI = NULL, return = F) {

  if(checkClass(AOI, 'sf')){
    AOI = sf::st_transform(AOI, '+proj=longlat +datum=WGS84')
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

  if(return){return(m)}

}


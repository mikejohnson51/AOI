 #' @title Generate Leafet map and tool set
#' @description Provides a precanned leaflet layout  for checking, and refining AOI queries. Useful \code{leaflet} tools allow for the marking of points, measuring of distances, and  panning and zooming.
#' @param AOI any spatial object (\code{raster}, \code{sf}, \code{sp}). Can be piped (\%>\%) from \code{\link{getAOI}}. If \code{AOI = NULL}, base map of CONUS will be returned.
#' @param returnMap \code{logical}. If \code{FALSE} (default) the input AOI is returned and the leaflet map printed. If \code{TRUE} the leaflet map is returned and printed.
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
#'          HydroData::findNWIS() # get SpatialPointsDataframe of local USGS gages
#'
#'      check(r$AOI) %>%
#'         addMarkers(data = r$nwis, popup = r$nwis$site_no)
#'
#' ## Save map for reference:
#'      m = getAOI("Kansas City") %>% check()
#'      htmlwidgets::saveWidget(m, file = paste0(getwd(), "/myMap.html"))
#' }
#' @export
#' @author Mike Johnson

check = function(AOI = NULL, returnMap = FALSE) {

  m = NULL
  bb = NULL
  pts = NULL

  orig = AOI

  if(!checkClass(AOI, "list")){ AOI = list(AOI = AOI)}

  type = NULL

  for( i in 1:length(AOI)){

    if(checkClass(AOI[[i]], 'sf')){
      AOI[[i]] = sf::st_transform(AOI[[i]], '+proj=longlat +datum=WGS84')
    }

    if(checkClass(AOI[[i]], 'raster')){
      bb = getBoundingBox(AOI[[i]]) %>% st_transform('+proj=longlat +datum=WGS84')
    }

  type[i] = tryCatch({
    as.character(unique(st_geometry_type(AOI[[i]])[1]))
  }, error = function(e) {
    NULL
  })
  }

  if("POINT" %in% type){
    pts = AOI[[which(grepl("POINT",type))]]
  }

  if("POLYGON" %in% type){
    bb = AOI[[which(grepl("POLYGON",type))]]
  }

  if("MULTIPOLYGON" %in% type){
    bb = AOI[[which(grepl("MULTIPOLYGON",type))]]
  }


  m = leaflet() %>%
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

  if(is.null(orig)){
    m = setView(m, lat = 39.311825, lng = -101.275972, zoom = 4)
  } else {

  if (!is.null(pts)) {
      m = addMarkers(m, data = pts)
  }

  if (!is.null(bb)) {

    m = addPolygons(m,
      data = bb,
      stroke = TRUE,
      fillColor = 'transparent',
      color = "red",
      opacity = 1
    )
  }
  }

  print(m)

  if(returnMap) {return(m)} else {return(orig)}

}


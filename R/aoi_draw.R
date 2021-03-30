#' @title AOI Draw
#' @description Interactivly draw an Area of Interest (AOI) using a shiny app. Once an object is drawn and the "Save AOI" button pressed,
#' a new sf object called 'aoi' will appear in you environment.
#' @return An sf object called 'aoi'.
#' @export
#' @importFrom shiny shinyApp bootstrapPage absolutePanel actionButton reactiveValues observeEvent isolate stopApp tags
#' @importFrom leaflet.extras addDrawToolbar drawRectangleOptions drawMarkerOptions drawPolygonOptions editToolbarOptions
#' @importFrom leaflet leafletOutput leaflet addProviderTiles setView
#' @importFrom sf st_sf st_sfc st_as_sf st_polygon st_cast
#'
#'
#' @examples \dontrun{
#' aoi_draw()
#' }
#'
#'
aoi_draw <- function() {

  tags = NULL
  shiny::shinyApp(

    ui <- bootstrapPage(
      shiny::tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
      leaflet::leafletOutput('aoi', width = "100%", height = "100%"),
      absolutePanel(bottom = 10, left = 10,
                    shiny::actionButton('save', "Save AOI", class = "btn-warning")
      )
    ),

    #server
    server = function(input, output, session) {

      output$aoi <- leaflet::renderLeaflet({

          leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          setView(lat = 35, lng = -100, zoom =4) %>%
            leaflet.extras::addDrawToolbar(polylineOptions     = FALSE,
                                           circleOptions       = FALSE,
                                           circleMarkerOptions = FALSE,
                                           rectangleOptions    = leaflet.extras::drawRectangleOptions(repeatMode = TRUE),
                                           markerOptions       = leaflet.extras::drawMarkerOptions(repeatMode = TRUE),
                                           polygonOptions      = leaflet.extras::drawPolygonOptions(repeatMode = TRUE),
                                           editOptions         = leaflet.extras::editToolbarOptions(edit = TRUE,
                                                                                                    remove = TRUE,
                                                                                                    selectedPathOptions = TRUE,
                                                                                                    allowIntersection = TRUE))
      })

      #store the sf in a reactiveValues
      values    <- shiny::reactiveValues()
      values$sf <- st_sf(st_sfc(crs = 4326))

      #update map with user input
      shiny::observeEvent(input$aoi_draw_new_feature, {

        coords       <- matrix(unlist(input$aoi_draw_new_feature$geometry$coordinates), ncol = 2, byrow = TRUE)
        feature_type <- input$aoi_draw_new_feature$properties$feature_type

        tmp <- shiny::isolate(sf::st_as_sf(sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(coords))), crs = 4326)))

        if(feature_type %in% c("rectangle","polygon")){
          new_sf <- tmp
        } else {
          new_sf <- sf::st_cast(tmp, "POINT")
        }

        shiny::isolate(values$sf <- rbind(values$sf, new_sf))

        #sf to return
        aoi  <<- values$sf

        #used to stop the app via button
        observeEvent(input$save, {
          message('Object saved as `aoi`')
          shiny::stopApp()
        })
      })

    }
  )
}




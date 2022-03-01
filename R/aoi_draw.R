#' Check for a package
#' @param pkg package name

check_pkg <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE))
    stop("Package '",
         pkg,
         "' is required for this functionality, but is not installed. \nTry `install.packages('",
         pkg,
         "')`", call. = FALSE)
}


#' @title AOI Draw
#' @description
#' Interactively draw an Area of Interest (AOI) using a shiny app.
#' Once an object is drawn and the "Save AOI" button pressed,
#' a new sf object called 'aoi' will appear in your environment.
#' @return An sf object called 'aoi'.
#' @export
#' @importFrom sf st_sf st_sfc st_as_sf st_polygon st_cast
#'
#' @examples \dontrun{
#' aoi_draw()
#' }

aoi_draw <- function() {

  check_pkg("shiny")
  check_pkg("leaflet")
  check_pkg("leaflet.extras")

  tags <- NULL
  shiny::shinyApp(

    ui <- shiny::bootstrapPage(
      shiny::tags$style(
        type = "text/css",
        "html, body {width:100%;height:100%}"
      ),
      leaflet::leafletOutput("aoi", width = "100%", height = "100%"),
      shiny::absolutePanel(
          bottom = 35, left = 10,
          shiny::textInput(
              "aoi_name",
              "AOI Object/File Name",
              placeholder = "e.g. my_aoi",
              width = "100%"
          )
      ),
      shiny::absolutePanel(
        bottom = 10, left = 10,
        shiny::actionButton(
          "save_to_object",
          "Save AOI to global environment",
          class = "btn-warning"
        ),
        shiny::actionButton(
          "save_to_file",
          "Save AOI to file",
          class = "btn-warning"
        )
      )
    ),

    # server
    server = function(input, output, session) {
      output$aoi <- leaflet::renderLeaflet({
        leaflet::leaflet()  |>
          leaflet::addProviderTiles('CartoDB.Positron') |>
          leaflet::setView(lat = 35, lng = -100, zoom = 4) |>
          leaflet.extras::addDrawToolbar(
            polylineOptions = FALSE,
            circleOptions = FALSE,
            circleMarkerOptions = FALSE,
            rectangleOptions = leaflet.extras::drawRectangleOptions(
              repeatMode = TRUE
            ),
            markerOptions = leaflet.extras::drawMarkerOptions(
              repeatMode = TRUE
            ),
            polygonOptions = leaflet.extras::drawPolygonOptions(
              repeatMode = TRUE
            ),
            editOptions = leaflet.extras::editToolbarOptions(
              edit = TRUE,
              remove = TRUE,
              selectedPathOptions = TRUE,
              allowIntersection = TRUE
            )
          )
      })

      # store the sf in a reactiveValues
      values    <- shiny::reactiveValues()
      values$sf <- sf::st_sf(sf::st_sfc(crs = 4326))

      # update map with user input
      shiny::observeEvent(input$aoi_draw_new_feature, {
        coords <- matrix(
          unlist(input$aoi_draw_new_feature$geometry$coordinates),
          ncol = 2,
          byrow = TRUE
        )
        feature_type <- input$aoi_draw_new_feature$properties$feature_type

        tmp <- shiny::isolate(
          sf::st_as_sf(
            sf::st_sf(
              geometry = sf::st_sfc(sf::st_polygon(list(coords))),
              crs = 4326
            )
          )
        )

        if (feature_type %in% c("rectangle", "polygon")) {
          new_sf <- tmp
        } else {
          new_sf <- sf::st_cast(tmp, "POINT")
        }

        shiny::isolate(values$sf <- rbind(values$sf, new_sf))

        # save aoi to a global object
        shiny::observeEvent(input$save_to_object, {
          shiny::validate(
            shiny::need(input$aoi_name, message = "AOI name is required")
          )

          assign(input$aoi_name, values$sf, envir = parent.frame())

          shiny::showNotification(
            paste0("Object saved as `", input$aoi_name, "`"),
            duration = NULL,
            type = "message",
            closeButton = FALSE
          )
          message(paste0("Object saved as `", input$aoi_name, "`"))
          shiny::stopApp()
        })

        # save aoi to a shapefile
        shiny::observeEvent(input$save_to_file, {
          shiny::validate(
            shiny::need(input$aoi_name, message = "AOI name is required")
          )
          if (!dir.exists("./aoi_draw/")) dir.create("./aoi_draw/")
          sf::st_write(
            obj = values$sf,
            dsn = paste0("aoi_draw/", input$aoi_name, ".gpkg")
          )
          shiny::showNotification(
            paste0("Object saved to `./aoi_draw/", input$aoi_name, ".gpkg`"),
            duration = NULL,
            type = "message",
            closeButton = FALSE
          )
          message(
            paste0("Object saved to `./aoi_draw/", input$aoi_name, ".gpkg`")
          )
          shiny::stopApp()
        })
      })
    }
  )
}

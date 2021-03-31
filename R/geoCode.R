#' @title Geocoding
#' @description
#' A wrapper around the OpenSteetMap geocoding web-services.
#' Users can request a lat/lon pair, spatial points, and/or
#' a bounding box geometries. One or more place name can be
#' given at a time. If a single point is requested, `geocode`
#' will provide a data.frame of lat/lon values and, if requested,
#' a spatial point object and the geocode derived bounding box.
#' If multiple place names are given, the returned objects will
#' be a data.frame with columns for input name-lat-lon; if requested,
#' a SpatialPoints object will be returned; and a minimum bounding box
#' of all place names.
#' @param location \code{character}. Place name(s)
#' @param zipcode \code{character}. USA zipcode(s)
#' @param event \code{character}. a term to search for on wikipedia
#' @param pt \code{logical}. If TRUE point geometery is appended
#'           to the returned list()
#' @param bb \code{logical}. If TRUE bounding box geometry is
#'           appended to the returned list()
#' @param full \code{logical}. If TRUE all OSM attributes reuturned
#'             with query, else just the lat/long pair.
#' @param all if TRUE the point and bounding box representations are returned
#' @return at minimum a data.frame of lat/lon coordinates.
#'         Possible list with appended spatial features of
#'         type \code{sf} or \code{sp}
#' @export
#' @author Mike Johnson
#' @examples
#' \dontrun{
#' ## geocode a single location
#' geocode("UCSB")
#'
#' ## geocode a single location and return a SpatialPoints object
#' geocode("UCSB", pt = TRUE)
#'
#' ## geocode a single location and derived bounding box of location
#' geocode("UCSB", bb = TRUE)
#'
#' ## geocode multiple locations
#' geocode(c("UCSB", "Goleta", "Santa Barbara"))
#'
#' ## geocode multiple points and generate a minimum bounding box of all locations and spatial points
#' geocode(c("UCSB", "Goleta", "Santa Barbara"), bb = T, pt = T)
#' }
#'
geocode <- function(location = NULL,
                    zipcode = NULL,
                    event = NULL,
                    pt = FALSE,
                    bb = FALSE,
                    all = FALSE,
                    full = FALSE) {
  if (!is.null(event)) {
    suppressWarnings({
      locs <- lapply(event, geocode_wiki) %>%
        bind_rows()
    })
  }

  if (!is.null(zipcode)) {
    zipcodes <- USAboundaries::us_zipcodes() %>%
      st_transform(4269)

    locs <- zipcodes[match(as.numeric(zipcode), zipcodes$zip), ] %>%
      na.omit()

    failed <- zipcode[!zipcode %in% locs$zip]
    if (length(failed) > 0) {
      warning("Zipcodes ", paste(failed, collapse = ", "), " not found.")
    }
    #> if(length(failed) > 0) {
    #>
    #>   xx = geocode(location = as.character(failed), full = T)
    #>
    #>   locs = rbind(locs, data.frame(
    #>     zip   = failed,
    #>     city  = strsplit(xx$display_name, ",")[[1]][1],
    #>     state = strsplit(xx$display_name, ",")[[1]][2],
    #>     lat   = xx$lat,
    #>     lon   = xx$lon,
    #>     timezone = NA,
    #>     dst = NA))
    #> }
  }

  if (!is.null(location)) {
    if (length(location) == 1) {
      return(geocodeOSM(location, pt, bb, all, full))
    } else {
      geoHERE <- function(x) {
        geocodeOSM(x, pt = FALSE, bb = FALSE, full = full)
      }

      latlon <- lapply(location, geoHERE) %>%
                dplyr::bind_rows()

      if (full) {
        locs <- latlon
        locs$lat <- as.numeric(locs$lat)
        locs$lon <- as.numeric(locs$lon)
      } else {
        locs <- data.frame(
          request = location,
          lat = as.numeric(latlon$lat),
          lon = as.numeric(latlon$lon)
        )
      }
    }
  }

  points <- st_as_sf(
    x = locs,
    coords = c("lon", "lat"),
    crs = 4269
  )

  if (!is.null(zipcode)) {
    points <- suppressMessages(suppressWarnings(
      st_intersection(points, aoi_get(state = "all"))
    ))
  }

  if (all) {
    return(list(coords = locs, pt = points, bb = bbox_get(points)))
  } else if (pt) {
    return(points)
  } else if (bb) {
    return(bbox_get(points))
  } else {
    return(locs)
  }
}

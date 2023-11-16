#' @title defineClip
#' @description
#' Parse a clip list from user input. \code{defineClip} parses
#' user supplied lists to a format usable by \code{\link{getClip}}
#' @param x a user supplied list (see \code{\link{aoi_get}})
#' @param km  \code{logical}. If \code{TRUE} distance are in kilometers,
#' default is \code{FALSE} with distances in miles
#' @noRd
#' @keywords internal
#' @return a 4-element list of features defining an AO

defineClip <- function(x = NULL, km = FALSE) {

  # AOI defined by location and bounding box width and height

  if (length(x) == 1) {
    if (!inherits(x, "character")) {
      stop(
        "If only one item is entered for 'x' it must be a character place name"
      )
    } else {
      location <- x
      h <- NULL
      w <- NULL
      o <- NULL
    }
  }

  if (length(x) == 3) {
    if (all(is.numeric(unlist(x)))) {
      stop(
        paste(
          "A x with length 3 must be defined by:",
          "1. A name (i.e 'UCSB') (character)",
          "2. A bound box height (in miles) (numeric)",
          "3. A bound box width (in miles) (numeric)",
          sep = "\n"
        )
      )
    } else {
      location <- x[[1]]
      h <- x[[2]]
      w <- x[[3]]
      o <- "center"
    }
  }

  # AOI defined by (centroid lat, long, and bounding box width and height)
  # or (loaction, width, height, origin)

  if (length(x) == 4) {
    if (any(
      !is.numeric(x[[2]]),
      !is.numeric(x[[3]]),
      all(!is.character(x[[1]]), is.character(x[[4]])),
      all(is.character(x[[1]]), !is.character(x[[4]]))
    )) {
      stop(
        paste0(
          "A x with length 4 must be defined by:\n",
          "1. A latitude (numeric)",
          "2. A longitude (numeric)\n",
          "2. A bounding box height (in miles) (numeric)\n",
          "3. A bounding box width (in miles) (numeric)\n\n",
          "OR\n\n",
          "1. A location (character)\n",
          "2. A bound box height (in miles) (numeric)\n",
          "3. A bounding box width (in miles) (numeric)\n",
          "4. A bounding box origin (character)"
        )
      )
    } else if (all(
      is.numeric(x[[1]]),
      is.numeric(x[[2]]),
      is.numeric(x[[3]]),
      is.numeric(x[[4]])
    )) {
      if (x[[1]] <= -90 | x[[1]] >= 90) {
        stop("Latitude must be vector element 1 and between -90 and 90")
      }

      if (x[[2]] <= -179.229655487 | x[[2]] >= 179.856674735) {
        stop("Longitude must be vector element 2 and between -180 and 180")
      }

      location <- c(x[[1]], x[[2]])
      h <- x[[3]]
      w <- x[[4]]
      o <- "center"
    } else if (all(
      is.character(x[[1]]),
      is.numeric(x[[2]]),
      is.numeric(x[[3]]),
      is.character(x[[4]])
    )) {
      location <- x[[1]]
      h <- x[[2]]
      w <- x[[3]]
      o <- x[[4]]
    }
  }

  # if AOI defined by lat, long, width, height, origin

  if (length(x) == 5) {
    if (all(
      is.numeric(x[[1]]),
      is.numeric(x[[2]]),
      is.numeric(x[[3]]),
      is.numeric(x[[4]]),
      is.character(x[[5]])
    )) {
      location <- c(x[[1]], x[[2]])
      h <- x[[3]]
      w <- x[[4]]
      o <- x[[5]]
    }
  }

  return(list(
    location = location,
    h = if (is.null(h)) {
      NULL
    } else {
      ifelse(km, (h * 0.62137119224), h)
    },
    w = if (is.null(w)) {
      NULL
    } else {
      ifelse(km, (w * 0.62137119224), w)
    },
    o = o
  ))
}


#' @title Convert clip unit ot geometry
#' @description
#' \code{getClip} generates a Spatial object based on a point;
#' bounding box dimisions; and their relation to the point.
#' @param location Defined by a location or lat, long pair
#' @param height   Define the height of the desired bounding box in miles
#' @param width    Define the width of the desired bounding box in miles
#' @param origin   Define the position of the point with respect to the
#'                 bounding box. Default is set to center. Options include:
#'                 \itemize{
#'                   \item{"center"}
#'                   \item{"lowerleft"}
#'                   \item{"lowerright"}
#'                   \item{"upperright"}
#'                   \item{"upperleft"}
#'                 }
#' @return a \code{SpatialPolygons} object projected to \emph{EPSG:4269}.
#' @export
#' @keywords internal



getClip <- function(x, km = FALSE) {

  fin <- defineClip(x, km = km)

  location <- fin$location

  origin   <- fin$o

  if (all(is.null(fin$h), is.null(fin$w), is.null(origin))) {
    poly <- geocode(location, bb = TRUE, full = FALSE)
  } else {
    if (inherits(location, "numeric")) {
      location <- list(lat = location[1], lon = location[2])
    }

    if (inherits(location, "character")) {
      location <- geocode(location = location, full = FALSE)
      if(is.na(location$lat)){stop("location not found in OSM", call. = FALSE)}
    }

    df <- (fin$h / 2) / 69 # north/south
    dl <- ((fin$w / 2) / 69) / cos(location$lat * pi / 180) # east/west

    if (origin == "center") {
      south <- location$lat - df
      north <- location$lat + df
      west <- location$lon - dl
      east <- location$lon + dl
    }

    if (origin == "lowerleft") {
      south <- location$lat
      north <- location$lat + (2 * df)
      west <- location$lon
      east <- location$lon + (2 * dl)
    }

    if (origin == "lowerright") {
      south <- location$lat
      north <- location$lat + (2 * df)
      west <- location$lon - (2 * dl)
      east <- location$lon
    }

    if (origin == "upperright") {
      south <- location$lat - (2 * df)
      north <- location$lat
      west <- location$lon - (2 * dl)
      east <- location$lon
    }

    if (origin == "upperleft") {
      south <- location$lat - (2 * df)
      north <- location$lat
      west <- location$lon
      east <- location$lon + (2 * dl)
    }

    poly <- st_bbox(c(xmin = west,
                      xmax = east,
                      ymin = south,
                      ymax = north), crs = 4326) %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf() %>%
      rename_geometry("geometry")
}
  return(poly)
}

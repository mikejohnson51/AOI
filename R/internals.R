rename_geometry = function(g, name) {
  current = attr(g, "sf_column")
  names(g)[names(g) == current] = name
  attr(g, "sf_column") <- name
  g
}


#' Returns a data.frame of valid states with abbreviations and regions
#'
#' @return data.frame of states with abbreviation and region
#' @export
#' @examples
#' \dontrun{
#' list_states()
#' }

list_states <- function() {
  return(data.frame(
    state_abbr   = datasets::state.abb,
    name   = datasets::state.name,
    region = datasets::state.region
  ))
}

#' Returns a sf data.frame of fipio data
#' @param state State names, state abbreviations, or one of the following: "all", "conus", "territories"
#' @param county County names or "all"
#' @return sf data.frame
#' @export
#' @examples
#' \dontrun{
#' fip_meta()
#' }
#' @importFrom sf st_as_sf
#' @importFrom fipio as_fips fips_metadata

fip_meta <- function(state, county = NULL) {

  fipio::as_fips(county = county, state = state) |>
    fipio::fips_metadata(geometry = TRUE) |>
    st_as_sf()
}


#' @title geocodeOSM
#' @description
#' Geocode via Open Street Maps API. \code{geocodeOSM}
#' takes an input string and converts it to a geolocation.
#' Additionally it can return the location as a simple
#' features point and the minimum bounding area
#' of the location extent.
#' @param location a place name
#' @param pt if TRUE a simple feature point is appended to returned list
#' @param bb if TRUE the OSM bounding area of the location is appended
#'           to returned list
#' @param all if TRUE the point and bounding box representations are returned
#' @param full \code{logical}. If TRUE all OSM attributes reuturned with query,
#'             else just the lat/long pair.
#' @return at minimum a data.frame of lat, long
#' @author Mike Johnson
#' @export
#' @examples
#' \dontrun{
#' geocodeOSM("UCSB")
#' geocodeOSM("Garden of the Gods", bb = TRUE)
#' }
#' @importFrom jsonlite fromJSON
#' @importFrom sf st_as_sf

geocodeOSM <- function(location, pt = FALSE, bb = FALSE,
                       all = FALSE, full = FALSE) {

  if (sum(pt, bb, all) > 1) {
    stop("Only pt, bb, or all can be TRUE. Leave others as FALSE")
  }

  if (class(location) != "character") {
    stop(paste(
      "",
      "Input location is not a place name. ",
      "You might be looking for reverse geocodeing.",
      "Try: AOI::geocode_rev()",
      sep = "\n"
    ))
  }

  URL <- paste0(
    "http://nominatim.openstreetmap.org/search?q=",
    gsub(" ", "+", location, fixed = TRUE),
    "&format=json&limit=1"
  )


  ret <- jsonlite::fromJSON(URL)

  rownames(ret) <- NULL

  if (length(ret) != 0) {
    s     <- data.frame(request = location, ret, stringsAsFactors = FALSE)
    s$lat <- as.numeric(s$lat)
    s$lon <- as.numeric(s$lon)
    s$licence <- NULL
    s$icon <- NULL
  } else {
    s <- data.frame(
      request = location,
      lat = NA,
      lon = NA,
      stringsAsFactors = FALSE
    )
  }

  sub <- data.frame(
    request = location,
    lat = s$lat,
    lon = s$lon,
    stringsAsFactors = FALSE
  )

  coords <- if (full) {
    s
  } else {
    sub
  }

  if (is.na(coords$lat)) {
    return(coords)
  }

  point <- sf::st_as_sf(x = coords, coords = c("lon", "lat"), crs = 4269)

  tmp.bb <- as.numeric(unlist(s$boundingbox))

  bbs <- st_bbox(c(xmin = tmp.bb[3],
                   xmax = tmp.bb[4],
                   ymin = tmp.bb[1],
                   ymax = tmp.bb[2]), crs = 4326) |>
    sf::st_as_sfc() |>
    sf::st_as_sf() |>
    rename_geometry("geometry")

  bbs$request <- s$request

  bbs <- if (full) {
           merge(bbs, s)
         } else {
           bbs
         }

  if (pt)  { return(point) }
  if (bb)  {  return(bbs)  }
  if (all) { return(list(coords = coords, pt = point, bbox = bbs)) }

  return(coords)
}

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

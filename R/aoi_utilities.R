#' @title Buffer AOI
#' @description Add or subtract a uniform distance to/from a
#'              spatial object in either miles or kilometers.
#' @param AOI a spatial, raster or simple features object
#' @param d \code{numeric}.The distance by which to modify each edge
#' @param km \code{logical}. If \code{TRUE} distances are in kilometers,
#'           default is \code{FALSE} with distances in miles
#' @return a spatial geometry of the same class as the input AOI
#'        (if Raster sp returned)
#' @export
#' @examples
#' \dontrun{
#' # get an AOI of 'Garden of the Gods' and add a 2 mile buffer
#' AOI <- aoi_get(x = "Garden of the Gods") %>% modify(2)
#'
#' # get an AOI of 'Garden of the Gods' and add a 2 kilometer buffer
#' getAOI("Garden of the Gods") %>% modify(2, km = TRUE)
#'
#' # get and AOI for Colorado Springs and subtract 3 miles
#' getAOI("Colorado Springs") %>% modify(-3)
#' }
#' @importFrom sf st_crs st_transform st_buffer

aoi_buffer <- function(AOI, d, km = FALSE) {
  AOI <- make_sf(AOI)

  crs <- sf::st_crs(AOI)

  if (km) {
    u <- d * 3280.84
  } # kilometers to feet
  if (!km) {
    u <- d * 5280
  } # miles to feet

  sf::st_transform(AOI, 6829)  %>%
    sf::st_buffer(
      dist = u,
      joinStyle = "MITRE",
      endCapStyle = "SQUARE",
      mitreLimit = 2
    )  %>%
    sf::st_transform(crs)
}

#' @title Is Inside
#' @description A check to see if one object is inside another
#' @param obj object 1
#' @param AOI object 2
#' @param total boolean.
#'              If \code{TRUE} then check if obj is completely
#'              inside the AOI (and vice versa: order doesn't matter).
#'              If \code{FALSE}, then check if at least part
#'              of obj is in the AOI.
#' @return boolean value
#' @export
#' @importFrom sf st_intersects st_intersection st_transform st_crs

aoi_inside <- function(AOI, obj, total = TRUE) {

  AOI <- make_sf(AOI)

  obj <- st_transform(make_sf(obj), st_crs(AOI))

  int <- suppressMessages(st_intersects(obj, AOI))

  if (!apply(int, 1, any)) {
    return(FALSE)
  } else {
    x <- suppressWarnings(
      suppressMessages(sf::st_intersection(obj, AOI))
    )

    inside <- any(x$geometry == AOI$geometry, x$geometry == obj$geometry)

    if (total) {
      return(inside)
    } else {
      return(TRUE)
    }
  }
}

#' @title Convert raster and sp objects to sf
#' @description Convert raster and sp objects to sf
#' @param x any spatial object
#' @return an sf object
#' @keywords internal
#' @importFrom sf st_as_sf

make_sf <- function(x) {
  if (inherits(x, "Raster")) {
    x <- bbox_get(x)
  } else if (inherits(x, "Spatial")) {
    x <- sf::st_as_sf(x)
  } else if (inherits(x, "data.frame")) {
    x <- sf::st_as_sf(x)
  } else {
    x <- NULL
  }

  x
}

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

  fipio::as_fips(county = county, state = state) %>%
    fipio::fips_metadata(geometry = TRUE) %>%
    st_as_sf()
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


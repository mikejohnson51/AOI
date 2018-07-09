#' Parse a clip list from user input
#'
#' @description \code{defineClip} parses user supplied lists to a format usable by \code{\link{getClip}}
#'
#' @seealso \code{\link{getClip}}
#' @seealso \code{\link{getAOI}}
#'
#' @param clip a user supplied list (see \code{\link{getAOI}})
#' @examples
#' \dontrun{
#' defineClip(list("UCSB", 10, 10))
#' defineClip(list(37,-115, 10, 10))
#' }
#'
#' @return a 4-element list of features defining an AOI including:
#' @author Mike Johnson
#' @export


defineClip = function(clip = NULL) {
  #------------------------------------------------------------------------------#
  # Clip Unit Defintion  (getClipUnit() for 3,4, or 5 inputs)                    #
  #------------------------------------------------------------------------------#

  if (grepl(
    pattern = "Spatial",
    class(clip),
    ignore.case = T,
    fixed = F
  )) {
    x = mean(clip@bbox[1, ])
    y = mean(clip@bbox[2, ])

    location <- c(y, x)
    h        <- round(abs(clip@bbox[2, 1] - clip@bbox[2, 2]) * 69, 0)
    w        <- round((abs(clip@bbox[1, 1] - clip@bbox[1, 2]) * 69) * (cos(y * pi / 180)), 0)
    o        <- "center"
  }

  if (grepl(
    pattern = "Raster",
    class(clip),
    ignore.case = T,
    fixed = F
  )) {
    e = raster::extent(clip)
    x = mean(e[1:2])
    y = mean(e[3:4])

    location <- c(y, x)
    h        <- round(abs(e[4] - e[3]) * 69, 0)
    w        <- round((abs(e[2] - e[1]) * 69) * (cos(y * pi / 180)), 0)
    o        <- 'center'
  }

  # AOI defined by location and bounding box width and height

  if (length(clip) == 3) {
    if (all(is.numeric(unlist(clip)))) {
      stop(
        paste0("A clip with length 3 must be defined by:\n",
            "1. A name (i.e 'UCSB') (character)\n",
            "2. A bound box height (in miles) (numeric)\n",
            "3. A bound box width (in miles) (numeric)"
        ))
    } else {
      location <- clip[[1]]
      h        <- clip[[2]]
      w        <- clip[[3]]
      o <- 'center'
    }
  }

  # AOI defined by (centroid lat, long, and bounding box width and height) or (loaction, width, height, origin)

  if (length(clip) == 4) {

  if (any(
      !is.numeric(clip[[2]]),
      !is.numeric(clip[[3]]),
      all(!is.character(clip[[1]]), is.character(clip[[4]])),
      all(is.character(clip[[1]]), !is.character(clip[[4]]))
    )) {
      stop(
        paste0("A clip with length 4 must be defined by:\n",
            "1. A latitude (numeric)",
            "2. A longitude (numeric)\n",
            "2. A bounding box height (in miles) (numeric)\n",
            "3. A bounding box width (in miles) (numeric)\n\n",
            "OR\n\n",
            "1. A location (character)\n",
            "2. A bound box height (in miles) (numeric)\n",
            "3. A bounding box width (in miles) (numeric)\n",
            "4. A bounding box origin (character)"
        ))



    } else if (all(
      is.numeric(clip[[1]]),
      is.numeric(clip[[2]]),
      is.numeric(clip[[3]]),
      is.numeric(clip[[4]])
    )) {
      if (all(-90  <= clip[[1]], clip[[1]] >= 90)) {
        stop("Latitude must be vector element 1 and between -90 and 90")
      }

      if (all(-179.229655487 <= clip[[2]], clip[[2]] >= 179.856674735)) {
        stop("Longitude must be vector element 2 and between -180 and 180")
      }

      location <- c(clip[[1]], clip[[2]])
      h      <- clip[[3]]
      w      <- clip[[4]]
      o      <- "center"

    } else if (all(
      is.character(clip[[1]]),
      is.numeric(clip[[2]]),
      is.numeric(clip[[3]]),
      is.character(clip[[4]])
    )) {
      location <- clip[[1]]
      h        <- clip[[2]]
      w        <- clip[[3]]
      o        <- clip[[4]]

    }
  }

  # if AOI defined by lat, long, width, height, origin

  if (length(clip) == 5) {
    if (all(
      is.numeric(clip[[1]]),
      is.numeric(clip[[2]]),
      is.numeric(clip[[3]]),
      is.numeric(clip[[4]]),
      is.character(clip[[5]])
    )) {
      location <- c(clip[[1]], clip[[2]])
      h        <- clip[[3]]
      w        <- clip[[4]]
      o        <- clip[[5]]
    }
  }

  return(list(
    location = location,
    h = h,
    w = w,
    o = o
  ))

  }

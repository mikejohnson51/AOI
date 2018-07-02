#' Interpret a clip unit from a user input
#'
#' @param clip_unit a user supplied input
#'
#' @return a list of features defining the AOI
#' @author Mike Johnson
#' @export
#'
#'


define.clip.unit = function(clip_unit) {
  #------------------------------------------------------------------------------#
  # Clip Unit Defintion  (getClipUnit() for 3,4, or 5 inputs)                    #
  #------------------------------------------------------------------------------#

  if (grepl(
    pattern = "Spatial",
    class(clip_unit),
    ignore.case = T,
    fixed = F
  )) {
    x = mean(clip_unit@bbox[1, ])
    y = mean(clip_unit@bbox[2, ])

    location <- c(y, x)
    h        <- round(abs(clip_unit@bbox[2, 1] - clip_unit@bbox[2, 2]) * 69, 0)
    w        <- round((abs(clip_unit@bbox[1, 1] - clip_unit@bbox[1, 2]) * 69) * (cos(y * pi / 180)), 0)
    o        <- "center"
  }

  if (grepl(
    pattern = "Raster",
    class(clip_unit),
    ignore.case = T,
    fixed = F
  )) {
    e = raster::extent(clip_unit)
    x = mean(e[1:2])
    y = mean(e[3:4])

    location <- c(y, x)
    h        <- round(abs(e[4] - e[3]) * 69, 0)
    w        <- round((abs(e[2] - e[1]) * 69) * (cos(y * pi / 180)), 0)
    o        <- 'center'
  }

  # AOI defined by location and bounding box width and height

  if (length(clip_unit) == 3) {
    if (all(is.numeric(unlist(clip_unit)))) {
      stop(
        cat("A clip_unit with length 3 must be defined by:\n",
            "1. A name (i.e 'UCSB') (character)\n",
            "2. A bound box height (in miles) (numeric)\n",
            "3. A bound box width (in miles) (numeric)"
        ))
    } else {
      location <- clip_unit[[1]]
      h        <- clip_unit[[2]]
      w        <- clip_unit[[3]]
      o <- 'center'
    }
  }

  # AOI defined by (centroid lat, long, and bounding box width and height) or (loaction, width, height, origin)

  if (length(clip_unit) == 4) {

  if (any(
      !is.numeric(clip_unit[[2]]),
      !is.numeric(clip_unit[[3]]),
      all(!is.character(clip_unit[[1]]), is.character(clip_unit[[4]])),
      all(is.character(clip_unit[[1]]), !is.character(clip_unit[[4]]))
    )) {
      stop(
        cat("A clip_unit with length 4 must be defined by:\n",
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
      is.numeric(clip_unit[[1]]),
      is.numeric(clip_unit[[2]]),
      is.numeric(clip_unit[[3]]),
      is.numeric(clip_unit[[4]])
    )) {
      if (all(-90  <= clip_unit[[1]], clip_unit[[1]] >= 90)) {
        stop("Latitude must be vector element 1 and between -90 and 90")
      }

      if (all(-179.229655487 <= clip_unit[[2]], clip_unit[[2]] >= 179.856674735)) {
        stop("Longitude must be vector element 2 and between -180 and 180")
      }

      location <- c(clip_unit[[1]], clip_unit[[2]])
      h      <- clip_unit[[3]]
      w      <- clip_unit[[4]]
      o      <- "center"

    } else if (all(
      is.character(clip_unit[[1]]),
      is.numeric(clip_unit[[2]]),
      is.numeric(clip_unit[[3]]),
      is.character(clip_unit[[4]])
    )) {
      location <- clip_unit[[1]]
      h        <- clip_unit[[2]]
      w        <- clip_unit[[3]]
      o        <- clip_unit[[4]]

    }
  }

  # if AOI defined by lat, long, width, height, origin

  if (length(clip_unit) == 5) {
    if (all(
      is.numeric(clip_unit[[1]]),
      is.numeric(clip_unit[[2]]),
      is.numeric(clip_unit[[3]]),
      is.numeric(clip_unit[[4]]),
      is.character(clip_unit[[5]])
    )) {
      location <- c(clip_unit[[1]], clip_unit[[2]])
      h        <- clip_unit[[3]]
      w        <- clip_unit[[4]]
      o        <- clip_unit[[5]]
    }
  }

  return(list(
    location = location,
    h = h,
    w = w,
    o = o
  ))

  }
